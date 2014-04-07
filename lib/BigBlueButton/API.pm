package BigBlueButton::API;

=encoding utf-8

=head1 NAME

BigBlueButton::API

=head1 SYNOPSIS

    use BigBlueButton::API;

    my $bbb = BigBlueButton::API->new( server => 'bbb.myhost', secret => '1234567890' );
    my $res = $bbb->get_version;

    if ( $response->success ) {
        my $version = $res->response->version
    }
    else {
        warn "Error occured: " . $res->error . ", Status: " . $res->status;
    }

=head1 DESCRIPTION

BigBlueButton::API is API for BBB

=cut

use 5.008005;
use strict;
use warnings;

use Carp qw/ confess /;
use LWP::UserAgent;

use BigBlueButton::API::Response;

use base qw/ BigBlueButton::API::Requests /;

use constant REQUIRE_PARAMS => qw/ secret server /;

our $VERSION = "0.01";

sub new {
    my $class = shift;

    $class = ref $class || $class;

    my $self = {
        timeout => 30,
        secret  => '',
        server  => '',
        use_https => 0,
        (@_),
    };

    for my $need_param ( REQUIRE_PARAMS ) {
        confess "Parameter $need_param required!" unless $self->{ $need_param };
    }

    return bless $self, $class;
}

sub abstract_request {
    my ( $self, $data ) = @_;

    my $request = delete $data->{request};
    my $checksum = delete $data->{checksum};
    confess "Parameter request required!" unless $request;

    my $url = $self->{use_https} ? 'https://' : 'http://';
    $url .= $self->{server} . '/bigbluebutton/api/' . $request . '?';

    if ( scalar keys %{ $data } > 0 ) {
        $url .= $self->generate_url_query( $data );
        $url .= '&';
    }
    $url .= 'checksum=' . $checksum;

    return $self->request( $url );
}

sub request {
    my ( $self, $url ) = @_;

    my $ua = LWP::UserAgent->new;

    $ua->ssl_opts(verify_hostname => 0) if $self->{use_https};
    $ua->timeout( $self->{ timeout } );

    my $res = $ua->get( $url );

    return BigBlueButton::API::Response->new( $res );
}

1;

__END__

=head1 AUTHOR

Alexander Ruzhnikov E<lt>ruzhnikov85@gmail.comE<gt>

=cut

