# vim:set et sw=2 ts=8 ft=perl:

$latex = 'uplatex --kanji=utf8';
$biber = 'biber -u -U --output_safechars';
$bibtex = 'upbibtex';
$dvipdf ='dvipdfmx %O -o %D %S';
$makeindex = 'upmendex %O -o %D %S';
$max_repeat = 5;
$pdf_mode = 3;

if ($^O eq 'linux') {
  $pdf_previewer = 'xdg-open';
} elsif ($^O eq 'darwin') {
  if (-d '/Applications/Skim.app') {
    $pdf_previewer = 'open -ga /Applications/Skim.app'
  } else {
    $pdf_previewer = 'open -g';
  }
}
