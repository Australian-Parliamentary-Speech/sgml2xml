# PSSSourceXML

`PSSSourceXML` downloads all Hansard XML files that have been published (1998 onward), by crawling the sitemap on the Parlinfo website. It's one of four submodules that make up the [ParlinfoSpeechScraper](../../) pipeline.

## Output layout

Given an output directory (`output/` by default), files land in:

```
output/source_xml/<house>/
├── sitemaps/                                # raw sitemap xml pages
├── htmls/                                   # downloaded hansard html pages
├── interim/                                 # intermediate url and link-diff files
├── xmls/<year>/<year>_<month>_<day>.xml     # xml output
└── logs/                                    # log output
```
