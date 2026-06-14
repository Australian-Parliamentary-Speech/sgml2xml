module PSSSourceSGML

using PythonCall
using ArgParse
using Dates
using ProgressMeter
using Logging
using LoggingExtras
using PSSUtils


#
# === Constants ===
#

const SGMLLinks::AbstractString = "HansardSGML.csv"

#
# === Types ===
# 

@enum SSGMLHouse house senate
@enum SSGMLSteps Step1 Step2 Step3

struct SSGMLPaths
    base::AbstractString
    sgmls::AbstractString
    xmls::AbstractString
    log::AbstractString
end

function SSGMLPaths(output::AbstractString, ssgml_house::AbstractString)
    base = joinpath(output, "source_sgml", ssgml_house)
    sgmls = joinpath(base, "sgmls")
    xmls = joinpath(base, "xmls")
    log = joinpath(base, "logs")
    return SSGMLPaths(base, sgmls, xmls, log)
end

function ArgParse.parse_item(::Type{SSGMLHouse}, x::AbstractString)
    for v in instances(SSGMLHouse)
        string(v) == x && return v
    end
end

#
# === Utility Functions ===
# 

function sgml2xml(fn, outputfn)
    bs4 = pyimport("bs4")
    BeautifulSoup = bs4.BeautifulSoup
    function xml_generate(fn, outputfn)
        sgml_content = read(fn, String)
        soup = BeautifulSoup(sgml_content, "lxml")
        # Convert to string without prettify to avoid stack overflow on deeply nested structures
        xml_content = pyconvert(String, pystr(soup))
        xml_content = replace(xml_content, "<!DOCTYPE hansard PUBLIC \"-//PARLINFO//DTD HANSARD STORAGE//EN\">" => "<!DOCTYPE hansard PUBLIC \"-//PARLINFO//DTD HANSARD STORAGE//EN\" \"hansard.dtd\">")
        open(outputfn, "w") do file
            write(file, xml_content)
        end
    end
    xml_generate(fn, outputfn)
end

#
# === CLI and Logging ===
# 

function get_args()
    s = ArgParseSettings()

    @add_arg_table! s begin
        "ssgml_house"
        required = true
        arg_type = SSGMLHouse
        help = "One of `" * join(string.(instances(SSGMLHouse)), ", ") * "`"
        "--output", "-o"
        required = false
        arg_type = AbstractString
        default = "output"
        help = "Output directory, defaults to `output/`"
    end
    return parse_args(s; as_symbols=true)
end

function get_logger(path::AbstractString)
    mkpath(path)
    log = joinpath(path, "$(today()).log")
    rm(log, force=true)
    return TeeLogger(
        global_logger(),
        MinLevelLogger(
            FileLogger(log),
            Logging.Info
        ),
    )
end

#
# === Main ===
#

function run(; ssgml_house::SSGMLHouse, output::AbstractString)::Bool
    paths = SSGMLPaths(output, string(ssgml_house))
    if isfile(paths.base * ".tar.gz")
        @info "Decompressing previous run..."
        decompress(paths.base * ".tar.gz", paths.base, clear=true)
    end
    logger = get_logger(paths.log)
    success = with_logger(logger) do
        return run(Val(Step1); paths=paths, ssgml_house=ssgml_house)
    end
    return success
end

function run(::Val{Step1}; paths::SSGMLPaths, ssgml_house::SSGMLHouse)::Bool
    path = paths.sgmls
    mkpath(path)
    date = string(today())
    debug = joinpath(paths.log, date * "_download.csv")
    file = joinpath(dirname(@__FILE__), SGMLLinks)
    lines = readlines(file)[2:end]
    if isdir(path) && length(readdir(path)) == length(lines)
        @info "Step 1 already completed as $(path) exists and is populated, skipping..."
    else
        @info "Running step 1: Downloading $(length(lines)) sgm files..."
        open(debug, "a") do io
            @showprogress for line in lines
                date, senate, reps = split(line, ",")
                link = "https://" * ((string(ssgml_house) == "house") ? reps : senate)
                if link == "https://"
                    continue
                end
                day, month, year = split(date, "/")
                out = joinpath(path, year, "$(year)_$(lpad(month, 2, "0"))_$(lpad(day, 2, "0")).sgm")
                mkpath(dirname(out))
                if isfile(out)
                    continue
                end
                try
                    download_file(link, out; retry=3)
                catch e
                    println(io, [link, e])
                end
            end
        end
    end
    return run(Val(Step2); paths=paths, ssgml_house=ssgml_house)
end

function run(::Val{Step2}; paths::SSGMLPaths, ssgml_house::SSGMLHouse)::Bool
    path = paths.xmls
    files = readdir(paths.sgmls, join=true)
    if isdir(path) && length(readdir(path)) == length(files)
        @info "Step 2 already completed as $(path) exists and is populated, skipping..."
    else
        @info "Running step 2: Converting $(length(readlines(joinpath(dirname(@__FILE__), SGMLLinks))) - 1) sgm files to xml files..."
        @showprogress for year in files
            for file in readdir(year, join=true)
                out = joinpath(path, split(split(file, basename(paths.sgmls))[end][2:end], ".")[1] * ".xml")
                mkpath(dirname(out))
                if isfile(out)
                    continue
                end
                sgml2xml(file, out)
            end
        end
    end
    return run(Val(Step3); paths=paths, ssgml_house=ssgml_house)
end

function run(::Val{Step3}; paths::SSGMLPaths, ssgml_house::SSGMLHouse)::Bool
    @info "Running step 3: Cleaning and compressing files..."
    # compress(paths.base, paths.base * ".tar.gz", clear=true)
    return true
end

export main
function (@main)(_ARGS)
    return run(; get_args()...) ? 0 : 1
end

end
