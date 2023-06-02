package File::IO {
    use strictures;
    use utf8;
    use English;

    use feature ":5.36";
    no warnings "experimental::smartmatch";
    use feature "switch";

    use boolean;
    use Return::Type;
    use Types::Standard -all;
    use Term::ANSIColor;
    use Syntax::Keyword::Try;
    use Throw qw(throw classify);
    use Value::TypeCheck;

    use FindBin;
    use lib "$FindBin::Bin/../lib";

    use Sys::Error 0.1.0;

    my $error = undef;

    our $VERSION = "0.1.0";

    $Throw::level = 1;

    sub new :ReturnType(Object) ($class) {
        type_check($class, Str);

        my $self = {};

        $error = Sys::Error->new();

        bless($self, $class);
        return $self;
    }


    our sub mode_translate :ReturnType(Str) ($self, $mode_string) {
        type_check($self, Object);
        type_check($mode_string, Str);

        my $mode = undef;
        given ($mode_string) {
            when ('r') {
                $mode = '<';
            }
            when ('rw') {
                $mode = '+<';
            }
            when ('tw') {
                $mode = '>';
            }
            when ('crw') {
                $mode = '+>';
            }
            when ('a') {
                $mode = '>>';
            }
            default {
                $mode = '<';
            }
        }
        return $mode;
    }

    our sub open :ReturnType(FileHandle, HashRef) ($self, $mode_string, $path) {
        type_check($self, Object);
        type_check($mode_string, Str);
        type_check($path, Str);

        my $fh = undef;
        my $mode = mode_translate($self, $mode_string);
        try {
            open($fh, $mode, $path) or throw(
                "Cannot open file", {
                    'trace' => 3,
                    'type'  => $error->error_string(int $OS_ERROR)->{'symbol'},
                    'info'  => "Attempted to open $path",
                    'code'  => int $OS_ERROR,
                    'msg'   => $error->error_string(int $OS_ERROR)->{'string'}
                }
            );
        } catch ($e) {
            classify(
                $e, {
                    default => sub {
                        # rethrow as a fatal
                        $error->err_msg($e, $error->error_string($ARG->{'string'}));
                        throw $e->{'error'}, {
                            'trace' => 3,
                            'type'  => $e->{'type'},
                            'code'  => $e->{'code'},
                            'msg'   => $e->{'msg'}
                        };
                    }
                }
            );
        }

        return ($fh,
            {
                'type' => 'OK',
                'code' => 0,
                'msg'  => 'Successful operation'
            }
        );
    }

    our sub read :ReturnType(Str, HashRef) ($self, $fh, $length) {
        type_check($self, Object);
        type_check($fh, FileHandle);
        type_check($length, (Int, Str));

        my $content = undef;
        try {
            read($fh, $content, $length);
            if ($OS_ERROR != 0) {
                throw "Cannot read from filehandle", {
                    'trace' => 3,
                    'type'  => $error->error_string($OS_ERROR)->{'symbol'},
                    'code'  => $OS_ERROR,
                    'msg'   => $error->error_string($OS_ERROR)->{'string'}
                };
            }
        } catch ($e) {
            classify(
                $e, {
                    default => sub {
                        # rethrow as fatal
                        $error->err_msg($e, $error->error_string($ARG->{'string'}));
                        throw $e->{'error'}, {
                            'trace' => 3,
                            'type'  => $e->{'type'},
                            'code'  => $e->{'code'},
                            'msg'   => $e->{'msg'}
                        };
                    }
                }
            );
        }

        return ($content,
            {
                'type' => 'OK',
                'code' => 0,
                'msg'  => 'Successful operation'
            }
        );
    }

    our sub close :ReturnType(HashRef) ($self, $fh) {
        type_check($self, Object);
        type_check($fh, FileHandle);

        try {
            close $fh or throw(
                "Cannot close filehandle", {
                    'trace' => 3,
                    'type'  => $error->error_string($OS_ERROR)->{'symbol'},
                    'code'  => $OS_ERROR,
                    'msg'   => $error->error_string($OS_ERROR)->{'string'}
                }
            );
        } catch ($e) {
            classify(
                $e, {
                    default => sub {
                        # rethrow as fatal
                        $error->err_msg($e, $error->error_string($ARG->{'string'}));
                        throw $e->{'error'}, {
                            'trace' => 3,
                            'type'  => $e->{'type'},
                            'code'  => $e->{'code'},
                            'msg'   => $e->{'msg'}
                        };
                    }
                }
            );
        }

        return {
            'type' => 'OK',
            'code' => 0,
            'msg'  => 'Successful operation'
        };
    }

    true;
}
