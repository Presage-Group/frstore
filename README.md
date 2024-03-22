
<!-- README.md is generated from README.Rmd. Please edit that file -->

# frstore

\<img src=“inst/figures/logo.png” align=“right” height=“138”
alt=“frstore logo /\>

<!-- badges: start -->
<!-- badges: end -->

{frstore} is an `R` interface to perform the create, read, update, and
delete (CRUD) operations on the Cloud Firestore database via REST API.

## Installation

You can install the development version of `frstore` like so:

``` r
remotes::install_github("udurraniAtPresage/frstore")
```

## Usage

`frstore` requires the Firebase project ID that you can obtain from the
project settings page. Put the Firebase project ID in your .Renviron as
`FIREBASE_PROJECT_ID`:

``` r
FIREBASE_PROJECT_ID = "<Firebase-Project-ID>"
```

Furthermore, `frstore` requires an access token to interact with the
Cloud Firestore database. [`frbs`
package](https://github.com/kennedymwavu/frbs/tree/main) provides useful
functions to sign up and sign in:

``` r
library(frbs)
# Sign up via Firebase authentication:
frbs_sign_up(email = "<EMAIL>", password = "<PASSWORD>")
# Sign in:
foo <- frbs_sign_in(email = "<EMAIL>", password = "<PASSWORD>")
```

`foo$idToken` provides the access token.

Functions in this package are named similar to the methods described in
the REST resource `v1beta1.projects.databases.documents` in the [Cloud
Firestore REST API
docs](https://cloud.google.com/firestore/docs/reference/rest). All
functions have the prefix `frstore_`. Currently, only these methods are
implemented as functions:

- createDocument  
- delete  
- get  
- patch

## Examples

### Create document(s)

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

### Read data

Get document(s) with all fields:

``` r
frstore_get("test", foo$idToken)
frstore_get("test/firstDoc", foo$idToken)
```

Get a specific field from a document:

``` r
frstore_get("test/firstDoc", foo$idToken, fields = c("age"))
```

### Update data

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

### Delete data

Suppose there is an existing document at
`test/firstDoc/firstCollection/doc` and we want to delete it:

``` r
frstore_delete("test/firstDoc/firstCollection/doc", foo$idToken)
```
