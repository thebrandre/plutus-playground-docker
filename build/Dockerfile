ARG PLUTUS_GIT_COMMIT=HEAD

FROM nixos/nix:2.3.12 AS plutus-core

RUN echo "substituters        = https://hydra.iohk.io https://iohk.cachix.org https://cache.nixos.org/" >> /etc/nix/nix.conf && \
	echo "trusted-public-keys = hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ= iohk.cachix.org-1:DpRUyj7h7V830dp/i6Nti+NEO2/nhblbov/8MW7Rqoo= cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=" >> /etc/nix/nix.conf

RUN apk add git

ARG PLUTUS_GIT_COMMIT
RUN git clone https://github.com/input-output-hk/plutus /opt/plutus && \
	cd /opt/plutus && \
	git checkout ${PLUTUS_GIT_COMMIT}

WORKDIR /opt/plutus
RUN nix-shell --run "nix build -f default.nix plutus.haskell.packages.plutus-core"
ENTRYPOINT [ "nix-shell", "--run" ]

FROM plutus-core AS plutus-playground

WORKDIR /opt/plutus/plutus-playground-client
RUN sed -i -e 's/localhost:8080/server:8080/g' default.nix && \
	sed -i -e 's/localhost:8080/server:8080/g' webpack.config.js && \
	sed -i -e 's/webpack-cli serve/webpack-cli serve --host=0.0.0.0/g' package.json

WORKDIR /opt/plutus
RUN nix-shell --run "cd plutus-playground-client && npm install && plutus-playground-generate-purs && npm run purs:compile && npm run webpack"

EXPOSE 8080
EXPOSE 8009

ENTRYPOINT [ "nix-shell", "--run" ]


FROM plutus-core AS plutus-docs
WORKDIR /opt/plutus

RUN nix-shell --run "nix-build default.nix -A docs.build-and-serve-docs"
EXPOSE 8002
ENTRYPOINT [ "nix-shell", "--run" ]


FROM plutus-core AS plutus-haddock-build

WORKDIR /opt/plutus
RUN nix-shell --run "nix-build --out-link /opt/plutus-haddock-build -A plutus-playground.haddock"


FROM nginx:1.20.1 AS plutus-haddock
COPY --from=plutus-haddock-build /opt/plutus-haddock-build/share/doc /usr/share/nginx/html
