package BigBlueButton::API::Response;

use 5.008005;
use strict;
use warnings;

use XML::Fast;

sub new {
    my ( $class, $res ) = @_;

    my $success   = $res->is_success;
    my $xml       = $success ? $res->decoded_content : '';
    my $error     = $success ? '' : $res->decoded_content;
    my $status    = $res->status_line;

    my $parsed_response = $xml ? xml2hash( $xml ) : {};

    return bless(
        {
            success  => $success,
            xml      => $xml,
            error    => $error,
            response => $parsed_response->{xml_result},
            status   => $status,
        }, $class
    );
}

sub xml {
    my ( $self ) = @_;

    return $self->{xml};
}

sub success {
    my ( $self ) = @_;

    return $self->{success};
}

# ...

1;