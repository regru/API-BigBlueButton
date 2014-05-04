# NAME

API::BigBlueButton

# SYNOPSIS

    use API::BigBlueButton;

    my $bbb = API::BigBlueButton->new( server => 'bbb.myhost', secret => '1234567890' );
    my $res = $bbb->get_version;

    if ( $response->success ) {
        my $version = $res->response->version
    }
    else {
        warn "Error occured: " . $res->error . ", Status: " . $res->status;
    }

# DESCRIPTION

API::BigBlueButton is module for work with API BBB

# LICENSE AND COPYRIGHT

This software is copyright (c) 2014 by REG.RU LLC.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

# AUTHOR

Alexander Ruzhnikov <a.ruzhnikov@reg.ru>
