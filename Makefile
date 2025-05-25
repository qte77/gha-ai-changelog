
.SILENT:
.ONESHELL:

.PHONY: setup setup_python setup_tool ruff act build_image push_image
.DEFAULT_GOAL := setup

ifndef GH_USER_NAME
GH_USER_NAME := $(shell which gh && gh api user -q '.login')
endif
ifndef IMAGE_NAME
IMAGE_NAME := bullseye-py3.13-nektos-act
endif
GHCR_URL := https://ghcr.io/v2/$(GH_USER_NAME)/$(IMAGE_NAME)/tags/list
IMAGE_URL := ghcr.io/$(GH_USER_NAME)/$(IMAGE_NAME)

setup:
	$(MAKE) -s setup_python
	$(MAKE) -s setup_tool TOOL=act
	$(MAKE) -s setup_tool TOOL=gh

setup_python:
	echo "Setting up Python ..."
	python3 -m venv .venv
	. .venv/bin/activate
	pip install -r requirements.txt
	deactivate

setup_tool:
	HOME_BIN="/home/vscode/.local/bin"
	if [ -z "$$TOOL" ]; then
		echo "⚠️  Usage: make setup_tool TOOL=<act|gh>"
		exit 1
	fi
	if which $$TOOL > /dev/null 2>&1; then
		echo "⚠️  $$TOOL is already installed: $$($$TOOL --version | head -n 1)"
		exit 0
	fi
	echo "⚠️  Installing $${TOOL} ..."
	if [ "$$TOOL" = "act" ]; then
		REPO="nektos/act"
		BIN_NAME="act"
		LATEST_TAG=$$(curl -s https://api.github.com/repos/$$REPO/releases/latest | jq -r .tag_name)
		TAR_NAME="act_Linux_x86_64.tar.gz"
	elif [ "$$TOOL" = "gh" ]; then
		REPO="cli/cli"
		BIN_NAME="gh"
		LATEST_TAG=$$(curl -s https://api.github.com/repos/$$REPO/releases/latest | jq -r .tag_name)
		if [ -z "$$LATEST_TAG" ]; then
			echo "Error fetching latest release tag."
			exit 1
		fi
		TAR_NAME="gh_$${LATEST_TAG#v}_linux_amd64.tar.gz"
	else
		echo "❌ Unsupported TOOL: $$TOOL"
		exit 1
	fi

	URL="https://github.com/$$REPO/releases/download/$${LATEST_TAG:-v0}/$$TAR_NAME"
	mkdir -p $$HOME_BIN
	TMP_DIR=$$(mktemp -d)
	echo "Downloading $$TOOL from $$URL"
	curl -fsSL --retry 3 "$$URL" | tar -xz -C $$TMP_DIR
	if [ "$$TOOL" = "gh" ]; then
		mv $$TMP_DIR/gh_*/bin/gh $$HOME_BIN
	else
		mv $$TMP_DIR/act $$HOME_BIN
		chmod +x $$HOME_BIN/act
	fi
	rm -rf $$TMP_DIR
	echo "$$TOOL installed: $$($$TOOL --version | head -n 1)"

ruff:
	. .venv/bin/activate
	ruff check --fix
	ruff format

act:
	. .venv/bin/activate
	act
	deactivate

build_image:
	echo "🔍 Checking for latest version tag on GHCR: $(IMAGE_URL)"
	@latest_tag=$$(docker manifest inspect $(IMAGE_URL):latest >/dev/null 2>&1 && echo "latest" || echo "")
	if [ -n "$$latest_tag" ]; then
		echo "✅ Found image on GHCR. Fetching tag list..."
		tags_json=$$(curl -s -H "Authorization: Bearer $$GHCR_TOKEN" $(GHCR_URL))
	else
		echo "⚠️  Could not access GHCR image. Falling back to local tag check."
		tags_json=$$( \
			docker images --format '{{.Repository}}:{{.Tag}}' | \
			grep '$(IMAGE_NAME):' | \
			sed 's/^.*://g' | \
			awk '{ print "\""$$1"\"" }' | \
			jq -s '{ "tags": . }' \
		)
	fi
	echo "⚠️  Tags found: $$tags_json"

	# Extract the latest semantic version tag
	latest_version=$$( \
		echo "$$tags_json" | jq -r '.tags[]' | \
		grep -E '^v[0-9]+\.[0-9]+\.[0-9]+$$' | \
		sort -V | tail -1 \
	)
	if [ -z "$$latest_version" ]; then
		IMAGE_TAG="v0.0.0"
	else
		version_numbers=$${latest_version#v}
		major=$$(echo $$version_numbers | cut -d. -f1)
		minor=$$(echo $$version_numbers | cut -d. -f2)
		patch=$$(echo $$version_numbers | cut -d. -f3)
		minor=$$((minor + 1))
		patch=0
		IMAGE_TAG="v$${major}.$${minor}.$${patch}"
	fi
	echo "🔖 Next image tag: $$IMAGE_TAG"

	# Check if tag exists remotely via docker manifest
	tag_exists_remote=$$(docker manifest inspect $(IMAGE_URL):$$IMAGE_TAG >/dev/null 2>&1 && echo yes || echo no)
	# Check if tag exists locally
	tag_exists_local=$$(docker image inspect $(IMAGE_URL):$$IMAGE_TAG >/dev/null 2>&1 && echo yes || echo no)

	if [ "$$tag_exists_remote" = "yes" ]; then
		echo "⚠️  Tag $$IMAGE_TAG already exists on GHCR. Skipping build."
	elif [ "$$tag_exists_local" = "yes" ]; then
		echo "⚠️  Tag $$IMAGE_TAG already exists locally. Skipping build."
	else
		echo "🚧 Building image $(IMAGE_URL):$$IMAGE_TAG..."
		docker build -t $(IMAGE_URL):$$IMAGE_TAG .
		docker tag $(IMAGE_URL):$$IMAGE_TAG $(IMAGE_URL):latest
		if [ -n "$$GHCR_TOKEN" ] && [ -n "$$GITHUB_OUTPUT" ]; then
			echo "IMAGE_TAG=$$IMAGE_TAG" >> $$GITHUB_OUTPUT
		fi
	fi

push_image:
	echo "Pushing Image $(IMAGE_URL):$$IMAGE_TAG ..."
	if [ -n "$${GHCR_TOKEN}" ]; then
		echo "$${GHCR_TOKEN}" | docker login ghcr.io -u "$(GH_USER_NAME)" --password-stdin
	else
		echo "⚠️  GHCR_TOKEN not set, skipping docker login"
	fi
	# echo "📤 Pushing image to GHCR..."
	docker push $(IMAGE_URL):$$IMAGE_TAG
	docker push $(IMAGE_URL):latest
