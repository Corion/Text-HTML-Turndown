package Text::HTML::Turndown::GFM 0.01;
use 5.020;
use experimental 'signatures';

=head1 NAME

Text::HTML::Turndown::GFM - rules for Github Flavoured Markdown

=head1 SYNOPSIS

  use Text::HTML::Turndown;
  my $turndown = Text::HTML::Turndown->new(%$options);
  $turndown->use('Text::HTML::Turndown::GFM');;

  my $markdown = $convert->turndown(<<'HTML');
    <table><tr><td>Hello</td><td>world!</td></tr></table>
  HTML
  # | Hello | world! |

=cut

sub install ($class, $target) {
    $target->use([
        'Text::HTML::Turndown::Tables',
        'Text::HTML::Turndown::Strikethrough',
        'Text::HTML::Turndown::Tasklistitems',
        'Text::HTML::Turndown::HighlightedCodeBlock',
    ]);
}

1;

=head1 SEE ALSO

L<Text::HTML::Turndown::Tables>

L<Text::HTML::Turndown::Strikethrough>

L<Text::HTML::Turndown::Tasklistitems>

L<Text::HTML::Turndown::HighlightedCodeBlock>

=cut
