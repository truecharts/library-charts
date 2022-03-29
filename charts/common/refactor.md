# Refactor info

## Restructure

Code will be structured as follows:

loader/definition -> spawner -> class -> lib

A loader or spawner can be called by an App, which creates one or more instances of a class, which includes libs that contain pre-defined behavior

### Standardised loaders

#### All Loader

- Loads all possible classes for usuall Apps without customisations


#### Split Loader

- *Init-Loader* Ensures values.yaml is parsed, modified and all variables are made available

- *Apply-Loader* Finishes loading the App itself

Between those any manual modifications can be side-loaded


### definition names

Definitions in common are to-be-named as follows:

common-*kind*-*optional_catagory*-*name*-*optional_subname*

For example:
`common-helper-service-primary`
