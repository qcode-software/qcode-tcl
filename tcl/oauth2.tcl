namespace eval qc::oauth2 {

    namespace export \
        authorize_code_url \
        token_request
    namespace ensemble create

    proc authorize_code_url {args} {
        #| Returns a URL to seek authorization code from a service.

        qc::args \
            $args \
            -state ? \
            -scope ? \
            -redirect_uri ? \
            server_url \
            client_id

        set response_type "code"

        return [qc::url \
                    $server_url \
                    ~ \
                    client_id \
                    response_type \
                    redirect_uri \
                    scope \
                    state \
                   ]
    }

    ############################################################################
    #
    # Token request procs to authorise access and obtain a valid access token.
    #
    ############################################################################
    namespace eval token_request {

        namespace export \
            authorization_code \
            password \
            client_credentials \
            refresh
        namespace ensemble create

        # Grant Types
        variable authorization_code_grant_type "authorization_code"
        variable password_grant_type           "password"
        variable client_credentials_grant_type "client_credentials"
        variable refresh_grant_type            "refresh_token"

        proc authorization_code {args} {
            #| Request authorisation using the Authorization Code grant type.

            qc::args \
                $args \
                -client_secret ? \
                -redirect_uri ? \
                -basic_auth true \
                -accept "application/json; charset=utf-8" \
                -valid_response_codes [list 200 400 401] \
                server_url \
                client_id \
                code

            variable authorization_code_grant_type

            set http_post_flags [dict create \
                                     -valid_response_codes $valid_response_codes \
                                    ]

            if { $accept ne "" } {
                dict set http_post_flags -accept $accept
            }

            set data [dict create \
                          grant_type $authorization_code_grant_type \
                          code $code \
                          ]

            if { [info exists client_secret] } {
                if { !$basic_auth } {
                    dict set data client_id $client_id
                    dict set data client_secret $client_secret
                } else {
                    set encoded_credentials [base64::encode \
                                                 -wrapchar "" \
                                                 "${client_id}:${client_secret}" \
                                                ]
                    dict set http_post_flags -authorization "Basic $encoded_credentials"
                }
            } else {
                dict set data client_id $client_id
            }

            if { [info exists redirect_uri] } {
                dict set data redirect_uri $redirect_uri
            }

            return [qc::http_post \
                        -response_headers true \
                        -response_code true \
                        {*}$http_post_flags \
                        $server_url \
                        {*}$data \
                       ]
        }

        proc password {args} {
            #| Request authorisation using the Password grant type.

            qc::args \
                $args \
                -client_id ? \
                -client_secret ? \
                -basic_auth true \
                -scope ? \
                -accept "application/json; charset=utf-8" \
                -valid_response_codes [list 200 400 401] \
                server_url \
                username \
                password

            variable password_grant_type

            set http_post_flags [dict create \
                                     -valid_response_codes $valid_response_codes \
                                    ]

            if { $accept ne "" } {
                dict set http_post_flags -accept $accept
            }

            set data [dict create \
                          grant_type $password_grant_type \
                          ]

            if { [info exists client_id]
                 && [info exists client_secret] } {
                if { !$basic_auth } {
                    dict set data client_id $client_id
                    dict set data client_secret $client_secret
                } else {
                    set encoded_credentials [base64::encode \
                                                 -wrapchar "" \
                                                 "${client_id}:${client_secret}" \
                                                ]
                    dict set http_post_flags -authorization "Basic $encoded_credentials"
                }
            }

            if { [info exists scope] } {
                dict set data scope $scope
            }

            return [qc::http_post \
                        -response_headers true \
                        -response_code true \
                        {*}$http_post_flags \
                        $server_url \
                        {*}$data \
                       ]
        }

        proc client_credentials {args} {
            #| Request authorisation using the Client Credentials grant type.

            qc::args \
                $args \
                -basic_auth true \
                -scope ? \
                -accept "application/json; charset=utf-8" \
                -valid_response_codes [list 200 400 401] \
                server_url \
                client_id \
                client_secret

            variable client_credentials_grant_type

            set http_post_flags [dict create \
                                     -valid_response_codes $valid_response_codes \
                                    ]

            if { $accept ne "" } {
                dict set http_post_flags -accept $accept
            }

            set data [dict create \
                          grant_type $client_credentials_grant_type \
                          ]

            if { !$basic_auth } {
                dict set data client_id $client_id
                dict set data client_secret $client_secret
            } else {
                set encoded_credentials [base64::encode \
                                             -wrapchar "" \
                                             "${client_id}:${client_secret}" \
                                            ]
                dict set http_post_flags -authorization "Basic $encoded_credentials"
            }

            if { [info exists scope] } {
                dict set data scope $scope
            }

            return [qc::http_post \
                        -response_headers true \
                        -response_code true \
                        {*}$http_post_flags \
                        $server_url \
                        {*}$data \
                       ]
        }

        proc refresh {args} {
            #| Request authorisation using the Refresh Token grant type.

            qc::args \
                $args \
                -client_id ? \
                -client_secret ? \
                -basic_auth true \
                -scope ? \
                -accept "application/json; charset=utf-8" \
                -valid_response_codes [list 200 400 401] \
                server_url \
                refresh_token

            variable refresh_grant_type

            set http_post_flags [dict create \
                                     -valid_response_codes $valid_response_codes \
                                    ]

            if { $accept ne "" } {
                dict set http_post_flags -accept $accept
            }

            set data [dict create \
                          grant_type $refresh_grant_type \
                          refresh_token $refresh_token \
                          ]

            if { [info exists client_id]
                 && [info exists client_secret] } {
                if { !$basic_auth } {
                    dict set data client_id $client_id
                    dict set data client_secret $client_secret
                } else {
                    set encoded_credentials [base64::encode \
                                                 -wrapchar "" \
                                                 "${client_id}:${client_secret}" \
                                                ]
                    dict set http_post_flags -authorization "Basic $encoded_credentials"
                }
            }

            if { [info exists scope] } {
                dict set data scope $scope
            }

            return [qc::http_post \
                        -response_headers true \
                        -response_code true \
                        {*}$http_post_flags \
                        $server_url \
                        {*}$data \
                       ]
        }
    }
}