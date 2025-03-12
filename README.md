# To get xmls from 1981-1996

Input required: HansardSGML.csv

The sgml2xml function downloads the sgml and converts them into xmls. 

To run house of representatives:

```julia
sgml2xml_run(:house)
```
To run senate:

```julia
sgml2xml_run(:senate)
```

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



