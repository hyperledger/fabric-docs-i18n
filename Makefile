# Adds support per each translation

docs-lang-es: TRANSLATION = es
docs-linkcheck-lang-es: TRANSLATION = es
docs-clean-lang-es:	TRANSLATION = es

docs-lang-ja_JP: TRANSLATION = ja_JP
docs-linkcheck-lang-ja_JP: TRANSLATION = ja_JP
docs-clean-lang-ja_JP: TRANSLATION = ja_JP

docs-lang-ml_IN: TRANSLATION = ml_IN
docs-linkcheck-lang-ml_IN: TRANSLATION = ml_IN
docs-clean-lang-ml_IN: TRANSLATION = ml_IN

docs-lang-pt_BR: TRANSLATION = pt_BR
docs-linkcheck-lang-pt_BR: TRANSLATION = pt_BR
docs-clean-lang-pt_BR: TRANSLATION = pt_BR

docs-lang-ru_RU: TRANSLATION = ru_RU
docs-linkcheck-lang-ru_RU: TRANSLATION = ru_RU
docs-clean-lang-ru_RU: TRANSLATION = ru_RU

docs-lang-zh_CN: TRANSLATION = zh_CN
docs-linkcheck-lang-zh_CN: TRANSLATION = zh_CN
docs-clean-lang-zh_CN: TRANSLATION = zh_CN

docs-lang-ta_IN: TRANSLATION = ta_IN
docs-linkcheck-lang-ta_IN: TRANSLATION = ta_IN
docs-clean-lang-ta_IN: TRANSLATION = ta_IN

# check if the translation language exists
TRANSLATION = no_value
.PHONY: verificate-translation
verificate-translation:
	@if [ $(TRANSLATION) = no_value ]; then \
		echo "Please use a language specific 'make' target such as: 'docs-lang-<language>' where '<language> is the i18n short code for your language"; \
		exit 1; \
	fi;

.PHONY: docs-lang-%
docs-lang-%: verificate-translation
	@echo "Generating translation for $(TRANSLATION)"
	@docker run -v $$(pwd)/docs:/docs hyperledger-fabric.jfrog.io/fabric-tox sh -c 'cd /docs/locale/$(TRANSLATION)/ && tox -e docs'

.PHONY: docs-linkcheck-lang-%
docs-linkcheck-lang-%: verificate-translation
	@docker run -v $$(pwd)/docs:/docs hyperledger-fabric.jfrog.io/fabric-tox sh -c 'cd /docs/locale/$(TRANSLATION)/ && tox -e docs-linkcheck'

.PHONY: clean
docs-clean-lang-%: verificate-translation
	@rm -rf docs/locale/$(TRANSLATION)/_build/
