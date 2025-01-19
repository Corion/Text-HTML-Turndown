package Text::HTML::Turndown::GFM 0.01;
use 5.020;
use experimental 'signatures';


sub install ($class, $target) {
    $target->use([
        'Text::HTML::Turndown::Tables',
        'Text::HTML::Turndown::Strikethrough',
        'Text::HTML::Turndown::Tasklistitems',
        'Text::HTML::Turndown::HighlightedCodeBlock',
    ]);
}

1;
