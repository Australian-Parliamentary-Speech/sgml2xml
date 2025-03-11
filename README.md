[![Documentation](https://github.com/Australian-Parliamentary-Speech/Scraper/actions/workflows/documentation.yml/badge.svg)](https://australian-parliamentary-speech.github.io/sgml2xml/)

# To run 1981-1996

To run house of representatives:

sgml2xml\_run(:house)

To run senate:

sgml2xml\_run(:senate)

# to run 1997 (only house)

1997 does not exist in the spreadsheet provided by the library. We generated the links using the function link\_gen(year,month,day):

```julia
    function link_gen(year,month,day)
        link = "parlinfo.aph.gov.au/parlInfo/download/chamber/hansardr/$(year)-$(month)-$(day)/toc_sgml/reps $(year)-$(month)-$(day).sgm"
        return link
    end
```

one\_year\_run()



