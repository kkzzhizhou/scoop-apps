check:	flake8 pep8

flake8:
	@for i in *.py ;\
	do \
		flake8 --ignore=E501 $$i ;\
	done

pep8:
	@for i in *.py ;\
	do \
		pep8 --ignore=E501 $$i ;\
	done

lint:	check pylint

pylint:
	@for i in *.py ;\
	do \
		pylint $$i ;\
	done

yapf:
	@for i in *.py ;\
	do \
		yapf -i $$i ;\
	done
