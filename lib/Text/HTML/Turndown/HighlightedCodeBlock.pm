package Text::HTML::Turndown::HighlightedCodeBlock 0.01;
use 5.020;
use experimental 'signatures';
use List::MoreUtils 'all';

our $highlightRegExp = qr/highlight-(?:text|source)-([a-z0-9]+)/;
our %RULES = (

    highlightedCodeBlock => {
        filter => sub ($rule, $node, $options) {
          my $firstChild = $node->firstChild;
          return (
            uc $node->nodeName eq 'DIV' &&
            $node->className =~ /$highlightRegExp/ &&
            $firstChild &&
            uc $firstChild->nodeName eq 'PRE'
          )
        },
        replacement => sub( $content, $node, $options, $context ) {
          my $className = $node->className || '';
          my $language = '';
          if( $className =~ /$highlightRegExp/) {
              $language = $1;
          };

          return (
            "\n\n" . $options->{fence} . $language . "\n" .
            $node->firstChild->textContent .
            "\n" . $options->{fence} . "\n\n"
          )
        }
    },
);

sub install ($class, $target) {
    for my $key (keys %RULES) {
        $target->addRule($key, $RULES{$key})
    }
}

1;
