package Text::HTML::Turndown::Tables 0.01;
use 5.020;
use experimental 'signatures';
use List::MoreUtils 'all';

our %RULES = (

    tableCell => {
        filter => ['th', 'td'],
        replacement => sub( $content, $node, $options, $context ) {
          return cell($content, $node);
        },
    },

    tableRow => {
        filter => 'tr',
        replacement => sub( $content, $node, $options, $context ) {
            my $borderCells = '';
            my $alignMap = { left => ':--', right => '--:', center => ':-:' };

            if (isHeadingRow($node)) {
                my @ch = $node->childNodes;
                for my $ch ($node->childNodes) {
                    my $border = '---';
                    my $align = lc(
                        $ch->getAttribute('align') || ''
                    );

                    if ($align) {
                        $border = $alignMap->{$align} || $border;
                    }

                    $borderCells .= cell($border, $ch)
                }
            }
            return "\n" . $content . ($borderCells ? "\n" . $borderCells : '')
        }
    },

    table => {
        # Only convert tables with a heading row.
        # Tables with no heading row are kept using `keep` (see below).
        filter => sub ($rule, $node, $options) {
            my $firstRow = $node->find('.//tr[0]')->unshift;
            return uc $node->nodeName eq 'TABLE' && isHeadingRow($firstRow)
        },

        replacement => sub( $content, $node, $options, $context ) {
            # Ensure there are no blank lines
            $content =~ s/\n\n/\n/;
            return "\n\n" . $content . "\n\n"
        }
    },

    tableSection => {
        filter => ['thead', 'tbody', 'tfoot'],
        replacement => sub( $content, $node, $options, $context ) {
            return $content
        }
    }
);

# A tr is a heading row if:
# - the parent is a THEAD
# - or if its the first child of the TABLE or the first TBODY (possibly
#   following a blank THEAD)
# - and every cell is a TH
sub isHeadingRow ($tr) {
    return if ! $tr;
    my $parentNode = $tr->parentNode;
    return (
      uc $parentNode->nodeName eq 'THEAD' ||
      (
           $tr->isEqual($parentNode->firstChild)
        && (uc $parentNode->nodeName eq 'TABLE' || isFirstTbody($parentNode))
        && all { uc($_->nodeName) eq 'TH' } $tr->childNodes
      )
    )
}

sub isFirstTbody ($element) {
  my $previousSibling = $element->previousSibling;
  return (
    uc $element->nodeName eq 'TBODY'
    && (
      !$previousSibling ||
      (
           uc $previousSibling->nodeName eq 'THEAD'
        && $previousSibling->textContent =~ /^\s*$/
      )
    )
  )
}

sub cell ($content, $node) {
  #my $index = indexOf.call(node.parentNode.childNodes, node)
  my $first = !$node->previousSibling;
  my $prefix = ' ';
  if ($first) { $prefix = '| ' };
  return $prefix . $content . ' |'
}

sub install ($class, $target) {
    $target->preprocess(sub($tree) {
        # We will likely need other/more rules to turn arbitrary HTML
        # into what a browser has as DOM for tables
        for my $table ($tree->find('//table')->@*) {
            # Turn <table><thead><td>...
            # into <table><thead><tr><td>...
            if( $table->find( './thead/td' )->@* ) {
                my $head = $table->find('./thead',$table)->shift;
                my $tr = $head->ownerDocument->createElement('tr');
                $tr->appendChild($_) for $head->childNodes;
                $head->appendChild( $tr );
            }
        }
        return $tree;
    });
    $target->keep(sub ($node) {
        my $firstRow = $node->find('.//tr')->shift;
        return uc $node->nodeName eq 'TABLE' && !isHeadingRow($firstRow)
    });
    for my $key (keys %RULES) {
        $target->addRule($key, $RULES{$key})
    }
}

1;
