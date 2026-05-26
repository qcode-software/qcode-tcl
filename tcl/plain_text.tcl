namespace eval qc {
    namespace export plain_text2html
}

proc qc::plain_text2html {plain_text} {
    #| Convert plain text to html. 
    set html [qc::html_escape $plain_text]
    set html [string map {\r\n <br> \n <br>} $html]
    return $html
}