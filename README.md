
<!-- README.md is generated from README.Rmd. Please edit that file -->

# frstore

<!-- badges: start -->
<!-- badges: end -->

{frstore} is an `R` interface to perform the create, read, update, and
delete (CRUD) operations on the Cloud Firestore database via REST API.

## Installation

You can install the development version of frstore like so:

``` r
# FILL THIS IN! HOW CAN PEOPLE INSTALL YOUR DEV PACKAGE?
```

{frstore} requires an access token to interact with the Cloud Firestore
database. [{frbs}](https://github.com/kennedymwavu/frbs/tree/main)
provides useful functions to sign up and sign in:

``` r
library(frbs)
# Sign up via Firebase authentication:
frbs_sign_up(email = "<EMAIL>", password = "<PASSWORD>")
# Sign in:
foo <- frbs_sign_in(email = "<EMAIL>", password = "<PASSWORD>")
```

`foo$idToken` provides the access token.

## Create document(s)

Create a document without specifying data:

``` r
library(frstore)
frstore_create_document("test/firstDoc", foo$idToken)
```

Create a document in a subcollection by providing the `data` argument:

``` r
data_list <- list(
  fields = list(
    age = list("integerValue" = 36),
    name = list("stringValue" = "merry")
 )
)
frstore_create_document("test/firstDoc/firstCollection/doc", foo$idToken, data_list)
```

Create a document in the main collection:

``` r
frstore_create_document("test/secondDoc", foo$idToken, data_list)
```

## Read data

Get document(s) with all fields:

``` r
frstore_get("test", foo$idToken)
frstore_get("test/doc", foo$idToken)
```

Get a specific field from a document:

``` r
frstore_get("test/doc", foo$idToken, fields = c("age"))
```

## Update data

Suppose there is an existing document at
`test/firstDoc/firstCollection/doc` and we want to update it with new
data:

``` r
data_list <- list(
   fields = list(
     age = list("integerValue" = 3600),
     name = list("stringValue" = "merryyyy")
   )
)
frstore_patch("test/firstDoc/firstCollection/doc", foo$idToken, data_list)
```

## Delete data

Suppose there is an existing document at
`test/firstDoc/firstCollection/doc` and we want to delete it:

``` r
frstore_delete("test/firstDoc/firstCollection/doc", foo$idToken)
```
