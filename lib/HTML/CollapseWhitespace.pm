package HTML::CollapseWhitespace 0.01;
use 5.020;
use experimental 'signatures';

=head1 NAME

HTML::CollapseWhitespace - remove extraneous whitespace from a fragment

=cut

sub collapseWhitespace (%options) {
  my $element = $options{ element }; # should be XML::LibXML
  my $isBlock = $options{ isBlock };
  my $isVoid  = $options{ isVoid  };
  my $isPre   = $options{ isPre } || sub ($node) {
    return uc($node->nodeName) eq 'PRE'
  };

  return
      if (!$element->firstChild || $isPre->($element));

  my $prevText;
  my $keepLeadingWs;

  my $prev;
  my $node = _next($prev, $element, $isPre);

  while (! $node->isEqual($element)) {
    if ($node->nodeType == 3 || $node->nodeType == 4) { # Node.TEXT_NODE or Node.CDATA_SECTION_NODE
      my $text = $node->data =~ s/[ \r\n\t]+/ /gr; # we only want to fold ASCII whitespace here

      if ((!$prevText || $prevText->data =~ / $/) &&
          !$keepLeadingWs && substr($text,0,1) eq ' ') {
        $text = substr($text, 1);
      }

      # `text` might be empty at this point.
      if (!$text) {
        $node = remove($node);
        next;
      }

      $node->setData( $text );

      $prevText = $node
    } elsif ($node->nodeType == 1) { # Node.ELEMENT_NODE
      if ($isBlock->($node) || uc $node->nodeName eq 'BR') {
        if ($prevText) {
            $prevText->setData( $prevText->data =~ s/ $//r );
        }
        undef $prevText;
        undef $keepLeadingWs;
      } elsif ($isVoid->($node) || $isPre->($node)) {
        # Avoid trimming space around non-block, non-BR void elements and inline PRE.
        undef $prevText;
        $keepLeadingWs = 1;
      } elsif ($prevText) {
        # Drop protection if set previously.
        undef $keepLeadingWs;
      }
    } else {
      $node = remove($node);
      next;
    }

    my $nextNode = _next($prev, $node, $isPre);
    $prev = $node;
    $node = $nextNode;
  }

  if ($prevText) {
    $prevText->{data} =~ s/ $//;
    if (!$prevText->{data}) {
      remove($prevText)
    }
  }
  return $element;
}

=head2 remove($note)

  my $next = remove( $node );

remove(node) removes the given node from the DOM and returns the
next node in the sequence.

=cut

sub remove ($node) {
  my $next = $node->nextSibling || $node->parentNode;

  $node->parentNode->removeChild($node);

  return $next
}

=head2 _next(prev, current, isPre)

  my $next = _next( $node );

returns the next node in the sequence, given the
current and previous nodes.

@param {Node} prev
@param {Node} current
@param {Function} isPre
@return {Node}

=cut

sub _next($prev, $current, $isPre) {
  if (($prev && $prev->parentNode->isEqual($current)) || $isPre->($current)) {
    return $current->nextSibling || $current->parentNode
  }

  return $current->firstChild || $current->nextSibling || $current->parentNode
}

1;

=head1 LICENSE

The collapseWhitespace function is adapted from collapse-whitespace
by Luc Thevenard.

The MIT License (MIT)

Copyright (c) 2014 Luc Thevenard <lucthevenard@gmail.com>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

 =cut
