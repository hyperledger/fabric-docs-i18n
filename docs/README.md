# Documentation README

## Introduction

This document contains information on how the Fabric documentation is
built and published as well as a few conventions one should be aware of
before making changes to the doc.

The crux of the documentation is written in
[reStructuredText](http://docutils.sourceforge.net/rst.html) which is
converted to HTML using [Sphinx](http://www.sphinx-doc.org/en/stable/).
The HTML is then published on http://hyperledger-fabric.readthedocs.io
which has a hook so that any new content that goes into `docs/source`
on the main repository will trigger a new build and publication of the
doc.

## Conventions

* Source files are in RST format and found in the `docs/source` directory.
* The main entry point is index.rst, so to add something into the Table
  of Contents you would simply modify that file in the same manner as
  all of the other topics. It's very self-explanatory once you look at
  it.
* Relative links should be used whenever possible. The preferred
  syntax for this is: :doc:\`anchor text &lt;relativepath&gt;\`
  <br/>Do not put the .rst suffix at the end of the filepath.
* For non RST files, such as text files, MD or YAML files, link to the
  file on github, like this one for instance:
  https://github.com/hyperledger/fabric/blob/master/docs/README.md

Notes: The above means we have a dependency on the github mirror
repository. Relative links are unfortunately not working on github
when browsing through a RST file.

## Setup

Making any changes to the documentation will require you to test your
changes by building the doc in a way similar to how it is done for
production. There are two possible setups you can use to do so:
setting up your own staging repo and publication website, or building
the docs on your machine. The following sections cover both options:

### Setting up your own staging repo and publication website

You can easily build your own staging repo following these steps:

1. Fork [fabric on github](https://github.com/hyperledger/fabric)
1. From your fork, go to `settings` in the upper right portion of the screen,
1. click `Integration & services`,
1. click `Add service` dropdown,
1. and scroll down to ReadTheDocs.
1. Next, go to http://readthedocs.org and sign up for an account. One of the first prompts will offer to link to github. Elect this then,
1. click import a project,
1. navigate through the options to your fork (e.g. yourgithubid/fabric),
1. it will ask for a name for this project. Choose something
intuitive. Your name will preface the URL and you may want to append `-fabric` to ensure that you can distinguish between this and other docs that you need to create for other projects. So for example:
`yourgithubid-fabric.readthedocs.io/en/latest`

Now anytime you modify or add documentation content to your fork, this
URL will automatically get updated with your changes!

### Building the docs on your machine

Here are the quick steps to achieve this on a local machine without
depending on ReadTheDocs, starting from the main fabric
directory. Note: you may need to adjust depending on your OS.

```
sudo pip install Sphinx
sudo pip install sphinx_rtd_theme
sudo pip install recommonmark==0.4.0
cd fabric/docs # Be in this directory. Makefile sits there.
make html
```

This will generate all the html files in `docs/build/html` which you can
then start browsing locally using your browser. Every time you make a
change to the documentation you will of course need to rerun `make
html`.

In addition, if you'd like, you may also run a local web server with the following commands (or equivalent depending on your OS):

```
sudo apt-get install apache2
cd build/html
sudo cp -r * /var/www/html/
```

You can then access the html files at `http://localhost/index.html`.

<a rel="license" href="http://creativecommons.org/licenses/by/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by/4.0/88x31.png" /></a><br />This work is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by/4.0/">Creative Commons Attribution 4.0 International License</a>.

process: x/96

access_control.md
arch-deep-dive.rst
architecture.rst
blockchain.rst
build_network.rst
capability_requirements.rst
chaincode4ade.rst
chaincode4noah.rst
chaincode.rst
channels.rst
channel_update_tutorial.rst
command_ref.rst
commands
configtx.rst
config_update.md
conf.py
CONTRIBUTING.rst
couchdb_as_state_database.rst
couchdb_tutorial.rst
DCO1.1.txt
developapps
dev-setup
diagrams
discovery-cli.md
discovery-overview.rst
enable_tls.rst
endorsement-policies.rst
error-handling.rst
Fabric-FAQ.rst
fabric_model.rst
fabric-sdks.rst
functionalities.rst
Gerrit
getting_started.rst
glossary
glossary.rst
gossip.rst
idemixgen.rst
idemix.rst
identity
images
index.rst
install.rst
jira_navigation.rst
kafka_raft_migration.md
kafka.rst
key_concepts.rst
ledger
ledger.rst
logging-control.rst
MAINTAINERS.rst
mdtorst.sh
membership
metrics_reference.rst
metrics_reference.rst.tmpl
msp-identity-validity-rules.rst
msp.rst
network
operations_service.rst
ops_guide.rst
orderer
orderer_deploy.md
peer-chaincode-devmode.rst
peer_event_services.rst
peers
pluggable_endorsement_and_validation.rst
policies.rst
prereqs.rst
private-data
private-data-arch.rst
private_data_tutorial.rst
questions.rst
raft_configuration.md
readwrite.rst
releases.rst
requirements.txt
security_model.rst
smartcontract
smartcontract.rst
_static
status.rst
Style-guides
submit_cr.rst
systemchaincode.rst
_templates
tutorial
tutorials.rst
txflow.rst
understand_fabcar_network.rst
upgrade_to_newest_version.rst
upgrading_your_network_tutorial.rst
usecases.rst
videos.rst
whatis.md
whatsnew.rst
write_first_app.rst
