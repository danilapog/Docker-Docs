## buildx bake configurations ###
variable "TAG" {
    default = "" 
}

variable "COMPANY_NAME" { 
    default = "onlyoffice" 
}

variable "PREFIX_NAME" { 
    default = ""
} 

variable "PRODUCT_EDITION" {
    default = ""
}

variable "DOCKERFILE" {
    default = "Dockerfile"
}

variable "DS_VERSION_HASH" {
    default = ""
}

variable "REGISTRY" {
    default = "docker.io"
}

variable "PRODUCT_BASEURL" {
    default = "https://download.onlyoffice.com/install/documentserver/linux/onlyoffice-documentserver"
}

variable "RELEASE_VERSION" {
    default = ""
}

variable "PLATFORM" {
    default = ""
}

variable "EXAMPLE_BRANCH" {
    default = "master"
}

variable "EXAMPLE_REPO" {
    default = "https://github.com/ONLYOFFICE/document-server-integration.git"
}

group "apps" {
    targets = ["proxy", "converter", "docservice", "example"]
}

target "example" {
    target = "example"
    dockerfile = "${DOCKERFILE}"
    tags = equal("docker.io",REGISTRY) ? ["docker.io/danilaworker/${PREFIX_NAME}docs-example:${TAG}"] : [
                                          "danilaworker/docs-example:${TAG}" ]
    platforms = ["${PLATFORM}"]
    args = {
        "PRODUCT_EDITION": "${PRODUCT_EDITION}"
        "EXAMPLE_BRANCH": "${EXAMPLE_BRANCH}"
        "EXAMPLE_REPO": "${EXAMPLE_REPO}"
    }
    ## Optional auth for a private EXAMPLE_REPO (e.g. the internal Gitea).
    ## Sourced from the GITEA_TOKEN env var; empty/unset for public GitHub builds.
    secret = ["id=example_token,env=GITEA_TOKEN"]
}
