using PyCall
using CSV
using HTTP
using ProgressMeter
using ArgParse
include("download_utils.jl")

function get_args()
    s = ArgParseSettings()
    @add_arg_table s begin
        "which_house"
            required = true
    end
    return parse_args(s)
end

function main()
    args = get_args()
    which_house = args["which_house"]
    sgml2xml_run(which_house)
    one_year_run(which_house)
end
 

function download_(url,outputname)
    response = get_response(url)
    open(outputname, "w") do file
        write(file, String(response.body))
    end
end

function sgml2xml(fn,outputfn)
    py"""
    from bs4 import BeautifulSoup

    def xml_generate(fn,outputfn):
        with open(fn, "r", encoding="utf-8") as file:           sgml_content = file.read()
        soup = BeautifulSoup(sgml_content, "lxml")
        xml_content = soup.prettify()
        xml_content = xml_content.replace('<!DOCTYPE hansard PUBLIC "-//PARLINFO//DTD HANSARD STORAGE//EN">', '<!DOCTYPE hansard PUBLIC "-//PARLINFO//DTD HANSARD STORAGE//EN" "hansard.dtd">')
        with open(outputfn, "w", encoding="utf-8") as file:
            file.write(xml_content)
    """
    py"xml_generate"(fn,outputfn)
end

function create_dir(directory_path::String)
    if !isdir(directory_path)
        mkpath(directory_path)
    end
end

function one_year_run(which_house)
    function link_gen(year,month,day)
        link = "parlinfo.aph.gov.au/parlInfo/download/chamber/hansardr/$(year)-$(month)-$(day)/toc_sgml/reps $(year)-$(month)-$(day).sgm"
        return link
    end

   year = 1997
    for month_ in 1:12
        for day_ in 1:31
            month,day = number_pro(month_),number_pro(day_)
            link = link_gen(year,month,day)
            link = "https://$link"
            sgml_fn = joinpath(pwd(),"$(which_house)_sgmls","$(day)_$(month)_$(year).sgm")
            create_dir(joinpath(pwd(),"$(which_house)_sgmls"))

            try
                download_(link,sgml_fn)
                xml_fn = joinpath(pwd(),"$(which_house)_xmls","1997","$(year)_$(month)_$(day).xml")
                create_dir(joinpath(pwd(),"$(which_house)_xmls","1997"))
                sgml2xml(sgml_fn,xml_fn)
            catch
                nothing
            end
        end
    end
end

function number_pro(num)
    if num < 10
        return "0$(num)"
    end
    return num
end

function sgml2xml_run(which_house)
    which_house = Symbol(which_house)
    csv_fn = "HansardSGML.csv"
    rows = CSV.Rows(csv_fn)
    failed = []
    row_no = 0
    for row in rows
        row_no += 1
        @show row_no
        date,senate,reps = row
        day,month,year = split(date,"/")
        month,day = number_pro(parse(Int,month)),number_pro(parse(Int,day))
        date = "$(year)_$(month)_$(day)"
 
        if which_house == :house
            chamber_link = reps
        elseif which_house == :senate
            chamber_link = senate
        end
        if !ismissing(chamber_link)
            full_chamber_link = "https://$chamber_link"
            sgml_fn = joinpath(pwd(),"$(which_house)_sgmls","$date.sgm")
            create_dir(joinpath(pwd(),"$(which_house)_sgmls"))

            try
                download_(full_chamber_link,sgml_fn)
                create_dir(joinpath(pwd(),"$(which_house)_xmls","$year"))
                xml_fn = joinpath(pwd(),"$(which_house)_xmls","$year","$date.xml")
                sgml2xml(sgml_fn,xml_fn)
            catch
                push!(failed,reps)
            end
        end
    end
    open("failed_sgml.csv", "w") do file
    for f in failed
        println(file, f)
    end
end
end
