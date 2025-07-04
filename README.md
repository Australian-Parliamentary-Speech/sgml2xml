# Install Julia

To run the package, Julia needs to be installed. For help see https://julialang.org/install/


# Download the SGML files and convert them to XML files
Step one, in your preferred directory, clone the sgml2xml repo with HTTP or SSH:
```
git clone https://github.com/Australian-Parliamentary-Speech/sgml2xml.git
```

Go into the directory
```
cd sgml2xml
```
 
In the directory, run:
```
./run house
```

or 
```
./run senate
```

The XML files should be in the directory senate\_xmls or house\_xmls



# to get xmls from 1997 (only house)

1997 does not exist in the spreadsheet provided by the library. We generated the links using the function link\_gen(year,month,day):

```julia
    function link_gen(year,month,day)
        link = "parlinfo.aph.gov.au/parlInfo/download/chamber/hansardr/$(year)-$(month)-$(day)/toc_sgml/reps $(year)-$(month)-$(day).sgm"
        return link
    end
```

one\_year\_run() also downloads the sgmls and converts them into xmls:

```julia
one_year_run()
```



