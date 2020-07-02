version = $(shell bin/walle -v)
filename= walle-$(version).tar.gz

dist: bin/walle lib/walle-cli-all.jar zsh-completion/_walle
	@tar zvcf $(filename) $^ && \
	command -v openssl > /dev/null && \
    openssl sha256 $(filename) && exit 0; \
    command -v sha256sum > /dev/null && \
    ha256sum $(filename)

download-walle-cli:
	curl -LO https://github.com/Meituan-Dianping/walle/releases/download/v$(version)/walle-cli-all.jar

clean:
	rm $(filename)

.PHONY: clean download-walle-cli
