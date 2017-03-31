TEMPLATE_RESOURCES_TARGETS = apache_resources.xml cyrus_resources.xml \
                             ldap_resources.xml \
			     mysql_resources.xml  postgres_resources.xml \
			     samba_resources.xml  smtp_resources.xml



TEMPLATE_CONSTRAINTS_TARGETS = apache_constraints.xml cyrus_constraints.xml \
                               ldap_constraints.xml postgres_constraints_order.xml \
			       samba_constraints_order.xml smtp_constraints.xml \
                               cyrus_constraints_order.xml \
			       mysql_constraints.xml postgres_constraints.xml \
			       samba_constraints.xml

TEMPLATE_CRM_CONFIG_TARGETS = crm_config.xml

TEMPLATE_TARGETS = $(TEMPLATE_CONSTRAINTS_TARGETS) $(TEMPLATE_RESOURCES_TARGETS) \
		   $(TEMPLATE_CRM_CONFIG_TARGETS)

CIBADMIN = /usr/sbin/cibadmin


.PHONY: all
all: $(TEMPLATE_TARGETS)

.PHONY: view
view: all
	@echo 'Cargando config inicial (crm_config)...'
	@$(foreach crm_config,$(TEMPLATE_CRM_CONFIG_TARGETS),\
                echo $(CIBADMIN) -o crm_config -C -x $(crm_config) &&) true
	
	@echo 'Cargando restricciones (constraints)...'
	@$(foreach constraint,$(TEMPLATE_CONSTRAINTS_TARGETS),\
                echo $(CIBADMIN) -o constraints -C -x $(constraint) &&) true
	
	@echo 'Cargando grupos de recursos (resources)...'
	@$(foreach resource,$(TEMPLATE_RESOURCES_TARGETS),\
                echo $(CIBADMIN) -o resources -C -x $(resource) &&) true




.PHONY: install
install: all
	@echo 'Cargando config inicial (crm_config)...'
	$(foreach crm_config,$(TEMPLATE_CRM_CONFIG_TARGETS),\
                $(CIBADMIN) -o crm_config -R -x $(crm_config) &&) true
	
	@echo 'Cargando restricciones (constraints)...'
	$(foreach constraint,$(TEMPLATE_CONSTRAINTS_TARGETS),\
                $(CIBADMIN) -o constraints -R -x $(constraint) &&) true
	
	@echo 'Cargando grupos de recursos (resources)...'
	$(foreach resource,$(TEMPLATE_RESOURCES_TARGETS),\
                $(CIBADMIN) -o resources -R -x $(resource) &&) true


.PHONY: fullinstall
fullinstall: all
	@echo -e '\n\a** Atención!!, a punto de destruir cib.xml . **\n'
	@echo -n "Interrumpa con Ctrl-C ahora si esto no es lo que desea... "
	@for I in 5 4 3 2 1 ; do echo -n "$$I " ; sleep 1 ; done
	@echo 'bye datos!'
	$(CIBADMIN) -E
	@echo 'Cargando config inicial (crm_config)...'
	$(foreach crm_config,$(TEMPLATE_CRM_CONFIG_TARGETS),\
                $(CIBADMIN) -o crm_config -C -x $(crm_config) &&) true
	
	@echo 'Cargando restricciones (constraints)...'
	$(foreach constraint,$(TEMPLATE_CONSTRAINTS_TARGETS),\
		$(CIBADMIN) -o constraints -C -x $(constraint) &&) true
	
	@echo 'Cargando grupos de recursos (resources)...'
	$(foreach resource,$(TEMPLATE_RESOURCES_TARGETS),\
		$(CIBADMIN) -o resources -C -x $(resource) &&) true

.PHONY: stop
stop: all
	@echo 'Eliminando restricciones (constraints)...'
	$(foreach constraint,$(TEMPLATE_CONSTRAINTS_TARGETS),\
                $(CIBADMIN) -o constraints -D -x $(constraint) &&) true
	
	@echo 'Eliminando grupos de recursos (resources)...'
	$(foreach resource,$(TEMPLATE_RESOURCES_TARGETS),\
                $(CIBADMIN) -o resources -R -x $(resource) &&) true

