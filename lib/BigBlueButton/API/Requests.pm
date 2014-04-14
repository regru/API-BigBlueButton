package BigBlueButton::API::Requests;

=head1 NAME

BigBlueButton::API::Requests

=cut

use 5.008008;
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


=head1 METHODS

=over

=item B<get_version($self)>

Getting the current version of the BigBlueButton

=cut

sub get_version {
    my ( $self ) = @_;

    my $url = $self->{use_https} ? 'https://' : 'http://';
    $url .= $self->{server} . '/bigbluebutton/api';

    return $self->request( $url );
}

=item B<create($self,%params)>

Create a meeting

%param:

name
    
    This parameter is optional.
    A name for the meeting.

meetingID
    
    This parameter is mandatory.
    A meeting ID that can be used to identify this meeting by the third party application.

attendeePW

    This parameter is optional.
    The password that will be required for attendees to join the meeting.

moderatorPW

    This parameter is optional.
    The password that will be required for moderators to join the meeting or for
    certain administrative actions (i.e. ending a meeting).

welcome
    
    This parameter is optional.
    A welcome message that gets displayed on the chat window when the participant joins.
    You can include keywords (%%CONFNAME%%, %%DIALNUM%%, %%CONFNUM%%) which
    will be substituted automatically.

dialNumber

    This parameter is optional.
    The dial access number that participants can call in using regular phone.

voiceBridge

    This parameter is optional.
    Voice conference number that participants enter to join the voice conference.

webVoice

    This parameter is optional.
    Voice conference alphanumberic that participants enter to join the voice conference.

logoutURL

    This parameter is optional.
    The URL that the BigBlueButton client will go to after users click the OK button
    on the 'You have been logged out message'.

record
    
    This parameter is optional.
    Setting 'record=true' instructs the BigBlueButton server to record the media and
    events in the session for later playback. Available values are true or false.
    Default value is false.

duration

    This parameter is optional.
    The duration parameter allows to specify the number of minutes for the meeting's length.
    When the length of the meeting reaches the duration, BigBlueButton automatically ends the meeting.

meta

    This parameter is optional.
    You can pass one or more metadata values for create a meeting.
    These will be stored by BigBlueButton and later retrievable via the getMeetingInfo call and
    getRecordings. Examples of meta parameters are meta_Presenter, meta_category, meta_LABEL, etc.
    All parameters are converted to lower case, so meta_Presenter would be the same as meta_PRESENTER.

redirectClient

    This parameter is optional.
    The default behaviour of the JOIN API is to redirect the browser to the Flash client when
    the JOIN call succeeds. There have been requests if it's possible to embed the Flash client
    in a "container" page and that the client starts as a hidden DIV tag which becomes visible
    on the successful JOIN. Setting this variable to FALSE will not redirect the browser but
    returns an XML instead whether the JOIN call has succeeded or not.
    The third party app is responsible for displaying the client to the user.

clientURL

    This parameter is optional.
    Some third party apps what to display their own custom client.
    These apps can pass the URL containing the custom client and when redirectClient
    is not set to false, the browser will get redirected to the value of clientURL

=cut

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

    my $data = $self->_generate_data( 'getMeetings' );
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
    my ( $self ) = @_;

    my $data = $self->_generate_data( 'getDefaultConfigXML' );
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
    $string .= $self->generate_url_query( $params ) if ( $params && ref $params );
    $string .= $self->{secret};

    return sha1_hex( $string );
}

sub generate_url_query {
    my ( $self, $params ) = @_;

    my $string = CORE::join( '&', map { "$_=$params->{$_}" } sort keys %{ $params } );

    return $string;
}

sub _generate_data {
    my ( $self, $request, $params ) = @_;

    $self->_check_params( $request, $params ) if $params;
    $params->{checksum} = $self->generate_checksum( $request, $params );
    $params->{request}  = $request;

    return $params;
}

sub _check_params {
    my ( $self, $request, $params ) = @_;

    my $const = 'REQUIRE_' . uc $request . '_PARAMS';
    return unless $self->can( $const );

    for my $req_param ( @{ $self->$const } ) {
        confess "Parameter $req_param required!" unless $params->{ $req_param };
    }

    return 1;
}

=back

=cut

1;