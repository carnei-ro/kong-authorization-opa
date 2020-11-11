VERSION := $(shell sed -n "s/.*VERSION.*= \{1,\}\(.*\)/\1/p;" opa/handler.lua)
NAME := $(shell basename $${PWD})
UID := $(shell id -u)
GID := $(shell id -g)
SUMMARY := $(shell sed -n '/^summary: /s/^summary: //p' README.md)
export UID GID NAME VERSION 

build: rockspec validate
	@find opa/ -type f -iname "*lua~" -exec rm -f {} \;
	@docker run --rm -u 0 -v ${PWD}:/plugin \
					--entrypoint /bin/bash kong:2.0.3-centos \
					-c "cd /plugin ; yum install -y zip; luarocks make > /dev/null 2>&1 ; luarocks pack ${NAME} 2> /dev/null ; chown ${UID}:${GID} *.rock"
	@mkdir -p dist
	@mv *.rock dist/
	@printf '\n\n Check "dist" folder \n\n'

validate:
	@if [ -z "$${VERSION}" ]; then \
	  printf "\n\nNo VERSION found in handler.lua;\nPlease set it in your object that extends the base_plugin.\nEx: plugin.VERSION = \"0.1.0-1\"\n\n"; \
	  exit 1 ;\
	else \
	  echo ${VERSION} | egrep '(\w.+)-([0-9]+)$$' > /dev/null 2>&1 ; \
	  if [ $${?} -ne 0 ]; then \
  	    printf "\n\nVERSION must follow the pattern [%%w.]+-[%%d]+\nWhich means: 0.0-0 or 0.0.0-0 or ...\nReceived: $${VERSION} \n\n"; \
	    exit 2 ; \
	  fi ; \
	fi
	@if [ -z "${SUMMARY}" ]; then \
  	  printf "\n\nNo SUMMARY found.\nPlease, create a 'README.md' file and place your summary there.\nFollow the pattern '^summary: '\nDo not use double quotes"; \
	  printf "\nExample:\nsummary: this is my summary\n\n\n" ;\
	  exit 4 ;\
	fi
	@if [ ! -f ${NAME}-${VERSION}.rockspec ]; then \
	  make rockspec; \
	fi

copy-docker-compose:
	@[ ! -f docker-compose.yaml ] && cp ../docker-compose.yaml . || printf ''

rockspec:
	@printf 'package = "%s"\nversion = "%s"\n\nsource = {\n url    = "git@github.com:carnei-ro/${NAME}.git",\n branch = "master"\n}\n\ndescription = {\n  summary = "%s",\n}\n\ndependencies = {\n  "lua ~> 5.1"\n}\n\nbuild = {\n  type = "builtin",\n  modules = {\n' "${NAME}" "${VERSION}" "${SUMMARY}" > ${NAME}-${VERSION}.rockspec
	@find opa -type f -iname "*.lua" -exec bash -c 'printf "    [\"kong.plugins.%s.%s\"] = \"%s\",\n" "${NAME}" "$$(basename $${1/\.lua})" "{}"' _ {} \;	>> ${NAME}-${VERSION}.rockspec
	@printf "  }\n}" >> ${NAME}-${VERSION}.rockspec

clean: copy-docker-compose
	@rm -rf *.rock *.rockspec dist shm opa/opa
	@find . -type f -iname "*lua~" -exec rm -f {} \;
	@docker-compose down -v

clear: clean

start: validate copy-docker-compose
	@docker-compose up -d

stop: copy-docker-compose
	@docker-compose down

logs: kong-logs
kong-logs:
	@docker logs -f $$(docker ps -qf name=${NAME}_kong_1) 2>&1 || true

shell: kong-bash
kong-bash:
	@docker exec -it $$(docker ps -qf name=${NAME}_kong_1) bash || true

reload: kong-reload
kong-reload:
	@docker exec -it $$(docker ps -qf name=${NAME}_kong_1) bash -c "/usr/local/bin/kong reload"

restart:
	@docker rm -vf $$(docker ps -qf name=${NAME}_kong_1)
	@docker-compose up -d

reconfigure: clean start kong-logs

config-aux:
	@[ ! -f aux.lua ] && echo -e 'ngx.say("hello from aux - edit aux.lua and run make patch-aux")\nngx.exit(200)' > aux.lua || printf ''
	@curl -s -X POST http://localhost:8001/services/ -d 'name=aux' -d url=http://localhost
	@curl -s -X POST http://localhost:8001/services/aux/routes -d 'paths[]=/aux'
	@curl -i -X POST http://localhost:8001/services/aux/plugins -F "name=pre-function" -F "config.functions=@aux.lua"

patch-aux:
	@curl -i -X PATCH http://localhost:8001/plugins/$$(curl -s http://localhost:8001/plugins/ | jq -r ".data[] |  select (.name|test(\"pre-function\")) .id")      -F "name=pre-function"      -F "config.functions=@aux.lua"
	@echo " "

req-aux:
	@curl -s http://localhost:8000/aux

populate-opa-server:
	@curl -iX PUT http://localhost:8181/v1/policies/carneiro --data-binary @opa_files/policy1.rego
	@curl -iX PUT localhost:8181/v1/data -d @opa_files/data.json -H content-type:application/json

config:
	@curl -s -X POST http://localhost:8001/services/ -d 'name=httpbin' -d url=http://httpbin.org/anything
	@curl -s -X POST http://localhost:8001/services/httpbin/routes -d 'paths[]=/' -d 'name=some_route_name_here'
	@curl -i -X POST http://localhost:8001/routes/some_route_name_here/plugins -d "name=${NAME}" -d "config.opa_host=opa_server" -d "config.opa_port=8181" -d "config.policy_uri=/v1/data/carneiro/policy1" -d "config.opa_result_boolean_key=deny" -d "config.opa_result_boolean_value=false" -d "config.use_redis_cache=true" -d "config.redis_host=redis"

config-plugin-remove:
	@curl -i -X DELETE http://localhost:8001/plugins/$$(curl -s http://localhost:8001/plugins/ | jq -r ".data[] |  select (.name|test(\"${NAME}\")) .id")

config-plugin-enable-debug:
	@curl -i -X PATCH http://localhost:8001/plugins/$$(curl -s http://localhost:8001/plugins/ | jq -r ".data[] |  select (.name|test(\"${NAME}\")) .id")      -F "name=${NAME}"      -F "config.debug=true"
	@echo " "

config-plugin-disable-debug:
	@curl -i -X PATCH http://localhost:8001/plugins/$$(curl -s http://localhost:8001/plugins/ | jq -r ".data[] |  select (.name|test(\"${NAME}\")) .id")      -F "name=${NAME}"      -F "config.debug=false"
	@echo " "

config-plugin-enable-cache:
	@curl -i -X PATCH http://localhost:8001/plugins/$$(curl -s http://localhost:8001/plugins/ | jq -r ".data[] |  select (.name|test(\"${NAME}\")) .id")      -F "name=${NAME}"      -F "config.use_redis_cache=true"
	@echo " "

config-plugin-disable-cache:
	@curl -i -X PATCH http://localhost:8001/plugins/$$(curl -s http://localhost:8001/plugins/ | jq -r ".data[] |  select (.name|test(\"${NAME}\")) .id")      -F "name=${NAME}"      -F "config.use_redis_cache=false"
	@echo " "

config-plugin-do-not-forward-headers:
	@curl -i -X PATCH http://localhost:8001/plugins/$$(curl -s http://localhost:8001/plugins/ | jq -r ".data[] |  select (.name|test(\"${NAME}\")) .id")      -F "name=${NAME}"      -F "config.forward_request_headers=NONE"
	@echo " "

config-plugin-forward-some-headers:
	@curl -i -X PATCH http://localhost:8001/plugins/$$(curl -s http://localhost:8001/plugins/ | jq -r ".data[] |  select (.name|test(\"${NAME}\")) .id")      -F "name=${NAME}"      -F "config.forward_request_headers=SOME" -F "config.forward_request_headers_names=content-type"
	@echo " "

remove-all:
	@for i in plugins consumers routes services upstreams; do for j in $$(curl -s --url http://127.0.0.1:8001/$${i} | jq -r ".data[].id"); do curl -s -i -X DELETE --url http://127.0.0.1:8001/$${i}/$${j}; done; done
