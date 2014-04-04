package BigBlueButton::API::Requests;

use 5.008005;
use strict;
use warnings;

use Digest::SHA1 qw/ sha1_hex /;
use Carp qw/ confess /;

use constant {
    REQUIRE_CREATE_PARAMS => [ qw/ meetingID / ],
    REQUIRE_JOIN_PARAMS   => [ qw/ fullName meetingID password / ],
    REQUIRE_ISMEETINGRUNNING_PARAMS  => [ qw/ meetingID / ],
    REQUIRE_END_PARAMS    => [ qw/ meetingID password / ],
    REQUIRE_GETMEETINGINFO_PARAMS    => [ qw/ meetingID password / ],
    REQUIRE_PUBLISHRECORDINGS_PARAMS => [ qw/ recordID publish / ],
    REQUIRE_DELETERECORDINGS_PARAMS  => [ qw/ recordID / ],
    REQUIRE_SETCONFIGXML_PARAMS      => [ qw/ meetingID configXML / ],
};

sub create {
    my ( $self, %params ) = @_;

    my $data = $self->_generate_data( 'create', \%params );
    return $self->abstract_request( $data );
}

sub join {
    my ( $self, %params ) = @_;

    my $data = $self->_generate_data( 'join', \%params );
    return $self->abstract_request( $data );
}

sub ismeetingrunning {
    my ( $self, %params ) = @_;

    my $data = $self->_generate_data( 'isMeetingRunning', \%params );
    return $self->abstract_request( $data );
}

sub end {
    my ( $self, %params ) = @_;

    my $data = $self->_generate_data( 'end', \%params );
    return $self->abstract_request( $data );
}

sub getmeetinginfo {
    my ( $self, %params ) = @_;

    my $data = $self->_generate_data( 'getMeetingInfo', \%params );
    return $self->abstract_request( $data );
}

sub getmeetings {
    my ( $self ) = @_;

    my $data = {};
    $data->{request}  = 'getMeetings';
    $data->{checksum} = $self->generate_checksum( $data->{request} );

    return $self->abstract_request( $data );
}

sub getrecordings {
    my ( $self, %params ) = @_;

    my $data = $self->_generate_data( 'getRecordings', \%params );
    return $self->abstract_request( $data );
}

sub publishrecordings {
    my ( $self, %params ) = @_;

    my $data = $self->_generate_data( 'publishRecordings', \%params );
    return $self->abstract_request( $data );
}

sub deleterecordings {
    my ( $self, %params ) = @_;

    my $data = $self->_generate_data( 'deleteRecordings', \%params );
    return $self->abstract_request( $data );
}

sub getdefaultconfigxml {
    my ( $self, %params ) = @_;

    my $data = $self->_generate_data( 'getDefaultConfigXML', \%params );
    return $self->abstract_request( $data );
}

sub setconfigxml {
    my ( $self, %params ) = @_;

    my $data = $self->_generate_data( 'setConfigXML', \%params );
    return $self->abstract_request( $data );
}

sub generate_checksum {
    my ( $self, $request, $params ) = @_;

    my $string = $request;

    if ( $params ) {
        $string .= CORE::join( '&', map { "$_=$params->{$_}" } keys %{ $params } );
    }

    $string .= $self->{secret};

    return sha1_hex( $string );
}

sub _generate_data {
    my ( $self, $request, $params ) = @_;

    $self->_check_params( $request, $params );
    $params->{checksum} = $self->generate_checksum( $request, $params );
    $params->{request}  = $request;

    return $params; 
}

sub _check_params {
    my ( $self, $request, $params ) = @_;

    my $const = 'REQUIRE_' . uc $request . '_PARAMS';
    return unless $self->$const;

    for my $req_param ( @{ $self->$const } ) {
        confess "Parameter $req_param required!" unless $params->{ $req_param };
    }

    return 1;
}

1;