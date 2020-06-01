package carneiro.policy1

test_deny_is_true_by_default {
  deny
}

test_deny_is_false_if_jwt_claim_role_is_root {
  not deny with input as { "cookies": { "oauth_jwt": "eyJhbGciOiJSUzUxMiIsInR5cCI6IkpXVCJ9.eyJpYXQiOjE1ODgzNjg0NDksImlzcyI6IktvbmciLCJuYW1lIjoiTGVhbmRybyBTb3V6YSBDYXJuZWlybyIsImRvbWFpbiI6Imlmb29kLmNvbS5iciIsImZhbWlseV9uYW1lIjoiQ2FybmVpcm8iLCJ1c2VyIjoibGVhbmRyby5jYXJuZWlybyIsInByb3ZpZGVyIjoiZ2x1dSIsInN1YiI6ImxlYW5kcm8uY2FybmVpcm9AaWZvb2QuY29tLmJyIiwiZW1haWxfdmVyaWZpZWQiOnRydWUsInJvbGVzIjpbInJvb3QiXSwiZ2l2ZW5fbmFtZSI6IkxlYW5kcm8iLCJleHAiOjE1ODg0NTQ4NDl9.m6-QL8Yp9D2f56zudsa6vF2BQ8tAMRp_NAZb2fC4ZA8G6oH9zZLviNxsTYI_cet0aoh9aNBhfIfLbl4DKLiciTXVvb5pldHK-9Tt8fQe42S7GQeqdrATJMflIJ9wiR9Ph3Gh1siMlgdAgcblV1z35YGFukdoAD_hta2UJEY8kJAV2p6KCpH-JdglMLf-D6mtUbub77MuTdp5jZWjXNpP8xxtmUBkwao_t5Yz7KDEznCcFF5F_3A4PCJcwX_svVVjMj3I1Ycu0atTBG-DD70IzvlfKwO8Tz3oVWKqcoP95JRPJuLwmz_aatoIget_LK3ggjNNAtBLjpGBqVCaBAt7LA" } } 
}

test_deny_is_false_if_jwt_claim_role_is_sre_and_method_is_get {
  not deny with input as { "method": "GET", "cookies": { "oauth_jwt": "eyJhbGciOiJSUzUxMiIsInR5cCI6IkpXVCJ9.eyJpYXQiOjE1ODgzNjg0NDksImlzcyI6IktvbmciLCJuYW1lIjoiTGVhbmRybyBTb3V6YSBDYXJuZWlybyIsImRvbWFpbiI6Imlmb29kLmNvbS5iciIsImZhbWlseV9uYW1lIjoiQ2FybmVpcm8iLCJ1c2VyIjoibGVhbmRyby5jYXJuZWlybyIsInByb3ZpZGVyIjoiZ2x1dSIsInN1YiI6ImxlYW5kcm8uY2FybmVpcm9AaWZvb2QuY29tLmJyIiwiZW1haWxfdmVyaWZpZWQiOnRydWUsInJvbGVzIjpbIlNSRSJdLCJnaXZlbl9uYW1lIjoiTGVhbmRybyIsImV4cCI6MTU4ODQ1NDg0OX0.j4DEDwUYdqa6y5yB2tUl_LnaN27SG9lAwdM7bxO8stVYLpvyxOZzqkOE7I00O_9lgGaqBB6R6P5q0YLXaqp5YSKKUtwooK65CXouglU_lY0PF78PrGnzNeNk2O7JQFMPW4Yi0e-RiTppQ--B3VJVnLx3onfCtaia9VgEEgG_Fb3YAvZfB6MsKlW8FzINmgc2nrYc_nbh-YBw9lKJ2xRWGpgYoQHdI0o5zdv_kYEK89sO3nnGnBinrcPS8XRKdk6EK8dfYsYEMzSlcPk8bEu0E_phg5bUa87WzkP6x2SGixVsQVTEldpyg-PNGhOZ9zWOSLk6y9YQF19y5UMQ9GrMTg" } } 
}

test_deny_is_false_if_jwt_claim_role_is_sre_and_method_is_patch {
  not deny with input as { "method": "PATCH", "cookies": { "oauth_jwt": "eyJhbGciOiJSUzUxMiIsInR5cCI6IkpXVCJ9.eyJpYXQiOjE1ODgzNjg0NDksImlzcyI6IktvbmciLCJuYW1lIjoiTGVhbmRybyBTb3V6YSBDYXJuZWlybyIsImRvbWFpbiI6Imlmb29kLmNvbS5iciIsImZhbWlseV9uYW1lIjoiQ2FybmVpcm8iLCJ1c2VyIjoibGVhbmRyby5jYXJuZWlybyIsInByb3ZpZGVyIjoiZ2x1dSIsInN1YiI6ImxlYW5kcm8uY2FybmVpcm9AaWZvb2QuY29tLmJyIiwiZW1haWxfdmVyaWZpZWQiOnRydWUsInJvbGVzIjpbIlNSRSJdLCJnaXZlbl9uYW1lIjoiTGVhbmRybyIsImV4cCI6MTU4ODQ1NDg0OX0.j4DEDwUYdqa6y5yB2tUl_LnaN27SG9lAwdM7bxO8stVYLpvyxOZzqkOE7I00O_9lgGaqBB6R6P5q0YLXaqp5YSKKUtwooK65CXouglU_lY0PF78PrGnzNeNk2O7JQFMPW4Yi0e-RiTppQ--B3VJVnLx3onfCtaia9VgEEgG_Fb3YAvZfB6MsKlW8FzINmgc2nrYc_nbh-YBw9lKJ2xRWGpgYoQHdI0o5zdv_kYEK89sO3nnGnBinrcPS8XRKdk6EK8dfYsYEMzSlcPk8bEu0E_phg5bUa87WzkP6x2SGixVsQVTEldpyg-PNGhOZ9zWOSLk6y9YQF19y5UMQ9GrMTg" } } 
}

test_deny_is_true_if_jwt_claim_role_is_sre_and_method_is_post {
  deny with input as { "method": "POST", "cookies": { "oauth_jwt": "eyJhbGciOiJSUzUxMiIsInR5cCI6IkpXVCJ9.eyJpYXQiOjE1ODgzNjg0NDksImlzcyI6IktvbmciLCJuYW1lIjoiTGVhbmRybyBTb3V6YSBDYXJuZWlybyIsImRvbWFpbiI6Imlmb29kLmNvbS5iciIsImZhbWlseV9uYW1lIjoiQ2FybmVpcm8iLCJ1c2VyIjoibGVhbmRyby5jYXJuZWlybyIsInByb3ZpZGVyIjoiZ2x1dSIsInN1YiI6ImxlYW5kcm8uY2FybmVpcm9AaWZvb2QuY29tLmJyIiwiZW1haWxfdmVyaWZpZWQiOnRydWUsInJvbGVzIjpbIlNSRSJdLCJnaXZlbl9uYW1lIjoiTGVhbmRybyIsImV4cCI6MTU4ODQ1NDg0OX0.j4DEDwUYdqa6y5yB2tUl_LnaN27SG9lAwdM7bxO8stVYLpvyxOZzqkOE7I00O_9lgGaqBB6R6P5q0YLXaqp5YSKKUtwooK65CXouglU_lY0PF78PrGnzNeNk2O7JQFMPW4Yi0e-RiTppQ--B3VJVnLx3onfCtaia9VgEEgG_Fb3YAvZfB6MsKlW8FzINmgc2nrYc_nbh-YBw9lKJ2xRWGpgYoQHdI0o5zdv_kYEK89sO3nnGnBinrcPS8XRKdk6EK8dfYsYEMzSlcPk8bEu0E_phg5bUa87WzkP6x2SGixVsQVTEldpyg-PNGhOZ9zWOSLk6y9YQF19y5UMQ9GrMTg" } } 
}

test_deny_is_false_if_jwt_claim_role_is_dba_and_method_is_get {
  not deny with input as { "method": "GET", "cookies": { "oauth_jwt": "eyJhbGciOiJSUzUxMiIsInR5cCI6IkpXVCJ9.eyJpYXQiOjE1ODgzNjg0NDksImlzcyI6IktvbmciLCJuYW1lIjoiTGVhbmRybyBTb3V6YSBDYXJuZWlybyIsImRvbWFpbiI6Imlmb29kLmNvbS5iciIsImZhbWlseV9uYW1lIjoiQ2FybmVpcm8iLCJ1c2VyIjoibGVhbmRyby5jYXJuZWlybyIsInByb3ZpZGVyIjoiZ2x1dSIsInN1YiI6ImxlYW5kcm8uY2FybmVpcm9AaWZvb2QuY29tLmJyIiwiZW1haWxfdmVyaWZpZWQiOnRydWUsInJvbGVzIjpbIkRCQSJdLCJnaXZlbl9uYW1lIjoiTGVhbmRybyIsImV4cCI6MTU4ODQ1NDg0OX0.Vc1HYpfTsTLorH-0qBLwMH3yS49JJg9Of2N-ov-xjPY1CISNKGkw62XVgmVd2ApmlqqCV18LAMgC_cXiKvpMGDUFXUOWVrd3pbcJ7jkqZzQL_OCiuWFzRxLTh5-waolj36kV-6UkhV3H3CxugWajdjhAMlk4Dtqn_OH7h7sqscnFdtB1D_-jTUjlj3ZaJYkx0evNyJOMmL6sj5RE0k0sXoh1iIAr-NYvPXWzw4D-DRlm8gxwuXbkl5CJ5l5ExUodw56zuTi5AdN4VirjF6chxJINHcBjcsOgMcod5u7RgB9aWKVmYrix2mfIslsFPkb_bC2rZPOM7Nd1r_S5Fz3UmA" } } 
}

test_deny_is_true_if_jwt_claim_role_is_dba_and_method_is_patch {
  deny with input as { "method": "PATCH", "cookies": { "oauth_jwt": "eyJhbGciOiJSUzUxMiIsInR5cCI6IkpXVCJ9.eyJpYXQiOjE1ODgzNjg0NDksImlzcyI6IktvbmciLCJuYW1lIjoiTGVhbmRybyBTb3V6YSBDYXJuZWlybyIsImRvbWFpbiI6Imlmb29kLmNvbS5iciIsImZhbWlseV9uYW1lIjoiQ2FybmVpcm8iLCJ1c2VyIjoibGVhbmRyby5jYXJuZWlybyIsInByb3ZpZGVyIjoiZ2x1dSIsInN1YiI6ImxlYW5kcm8uY2FybmVpcm9AaWZvb2QuY29tLmJyIiwiZW1haWxfdmVyaWZpZWQiOnRydWUsInJvbGVzIjpbIkRCQSJdLCJnaXZlbl9uYW1lIjoiTGVhbmRybyIsImV4cCI6MTU4ODQ1NDg0OX0.Vc1HYpfTsTLorH-0qBLwMH3yS49JJg9Of2N-ov-xjPY1CISNKGkw62XVgmVd2ApmlqqCV18LAMgC_cXiKvpMGDUFXUOWVrd3pbcJ7jkqZzQL_OCiuWFzRxLTh5-waolj36kV-6UkhV3H3CxugWajdjhAMlk4Dtqn_OH7h7sqscnFdtB1D_-jTUjlj3ZaJYkx0evNyJOMmL6sj5RE0k0sXoh1iIAr-NYvPXWzw4D-DRlm8gxwuXbkl5CJ5l5ExUodw56zuTi5AdN4VirjF6chxJINHcBjcsOgMcod5u7RgB9aWKVmYrix2mfIslsFPkb_bC2rZPOM7Nd1r_S5Fz3UmA" } } 
}

test_deny_is_true_if_jwt_does_not_have_claim_role {
  deny with input as { "cookies": { "oauth_jwt": "eyJhbGciOiJSUzUxMiIsInR5cCI6IkpXVCJ9.eyJpYXQiOjE1ODgzNjg0NDksImlzcyI6IktvbmciLCJuYW1lIjoiTGVhbmRybyBTb3V6YSBDYXJuZWlybyIsImRvbWFpbiI6Imlmb29kLmNvbS5iciIsImZhbWlseV9uYW1lIjoiQ2FybmVpcm8iLCJ1c2VyIjoibGVhbmRyby5jYXJuZWlybyIsInByb3ZpZGVyIjoiZ2x1dSIsInN1YiI6ImxlYW5kcm8uY2FybmVpcm9AaWZvb2QuY29tLmJyIiwiZW1haWxfdmVyaWZpZWQiOnRydWUsImdpdmVuX25hbWUiOiJMZWFuZHJvIiwiZXhwIjoxNTg4NDU0ODQ5fQ.X1pP1m5snUC79QyRnpH7ZqW8FaQn51dcu_XPh1uTcAGfrIhg1OpH8J1nNn6eVMnWF9sSn7LzHz46qrFYOuOHgSU133-Ed3CI-w22OXCA-bWBQWsjouUgAbqSMyLebri6mK7NVD-tqDgk8ttR1Gl4W6NcE903xXFix7JysUtrnUSHc6dLMbhmFJgNCij3ZOk0mzOLKrpe1CMS_OXe8_uI4HYnvRR7XTS_sRvxVV2B8eSc10jZHOwRrmHPUaMv7565W5BRYdY4SdoAPFs4mbm__Yhl-YGQ3ootipW6K9Fm9w6l12b3bBQ-ufUEuPkYwXC8MoLUJYO5F90fWUstyHiweQ" } } 
}
