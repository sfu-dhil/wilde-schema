# Transcribing and Editing

The following instructions apply to transcriptions of news reports in the Wilde Trials International News Archive.

## Template

Use the following template for transcribing news reports.

```xml
<html xmlns="http://www.w3.org/1999/xhtml">
  <head>
    <title>PAPER TITLE - DAY, MONTH, DATE YEAR</title>
    <meta name="dc.date" content="YYYY-MM-DD" />
    <meta name="dc.language" content="" />
    <meta name="dc.publisher" content="" />
    <meta name="dc.region" content="" />
    <meta name="dc.region.city" content="" />
    <meta name="dc.source.database" content="" />
    <meta name="dc.source.facsimile" content="" />
    <meta name="dc.source.url" content="" />
  </head>
  <body>
    <div id="original" lang="">
    <p class="heading">LINE 1<br />
    LINE 2</p>
    <p>This is a complete paragraph as [...] in a report.</p>
    <p class="signature">AUTHOR</p>
    </div>
  </body>
</html>
```

## Metadata

Enter the following metadata fields for each news report, following Dublin Core Standards.

* `dc.date` is the date the report was published. It must be formatted as shown.
* `dc.language` is the ISO code for the language of the report. It must be one of the following values. Additional language support can be added if necessary.
 * `de` German
 * `en` English
 * `es` Spanish
 * `fr` French
 * `it` Italian
* `dc.publisher` is the title of the newspaper.
* `dc.region` is the country or other national entity where the report was published. Examples include France, Australia, Britain (not "British", not "England"), and Canada.
* `dc.region.city` is the city where the newspaper was published
* `dc.source.database` is the database source for the report.
* `dc.source.institution` is the institutional source for the report.
* `dc.source.facsimile` is the facsimile page of the report.
* `dc.source.url` is the url for the digital newspaper or for the institutional catalogue that holds the original print copies.

## Content  

Enter the text of the news report within `<body>` tags.

The body of each news report must include `<div id="original" lang="">` and a corresponding `</div>` tag. The value of the `lang` attribute must match the `content` of the `dc.language` meta tag.

The content includes automatically generated translations of non-English reports. We also use `<div>` tags to distinguish the original and translated content.

### Headlines & Signatures

Headlines are marked up in paragraph tags (`<p>...</p>`) with the class set to "heading". Normal paragraphs do not include a class. 

Some news reports are signed. Those signatures are marked up in a paragraph with the class set to "signature". There are no other allowable classes for paragraphs.

### Formatting

Preserve the paragraph breaks of the original news report.

Line breaks (`<br/>`) can be used inside paragraphs. They cannot be used outside of paragraphs or anywhere else.

There is no need to respect the line breaks of the original news report, except in the case of headlines and short letters, telegrams or lines of poetry/literature. The new line should begin with a break: (`<br/>`)

For long letters, passages from literature, or testimony use paragraph breaks with paragraph tags: (`<p>`)


### Transcriptions

Use Unicode (UTF-8) consistently on all files to ensure the accented characters are encoded correctly.

Transcribe everything in the news report, even if misspelled. 

Preserve original capitalisation and punctuation. Note that it is not required to format italics or font changes, but text may be marked up as italicized (`<i>...</i>`) or bolded (`<b>...</b>`).

Use the M dash for dashes.

For English-language papers, use straight quotation marks (" ").

For French-language papers, use guillemets (« »). 

For German-language papers, use („…“).

For ampersands (&) in an xml document, including in a URL, type "&amp"


### Omitted/Unreadable Text

Any text that is unreadable in the original report is indicated with square brackets and three periods: `[...]`. Spaces are not allowed inside the square brackets or between the periods.
