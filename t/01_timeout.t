use strict;
use warnings;

use Test::More;
use Test::Fatal;

use Sub::Timeout;

subtest 'return before timeout' => sub {
    my $res = timeout 1, sub {
        return 'result';
    };
    is $res, 'result';
};

subtest 'timeout' => sub {
    my $error = exception {
        timeout 0.1, sub {
            sleep 1;
        };
    };
    is $error, 'Timeout. 0.1 seconds.';
};

subtest 'timeout and specify callback' => sub {
    my $res = timeout 0.1, sub {
        sleep 1;
    }, sub {
        return 'timeout';
    };
    is $res, 'timeout';
};

done_testing();
