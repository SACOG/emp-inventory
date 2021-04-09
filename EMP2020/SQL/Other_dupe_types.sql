/*
Other duplicate types:
	-2 records with 2 different addresses in different ZIPs will have same name, same NAICS, but only 1 of them
		will be a real business AND they are not just 2 franchises of a chain.
		-INDFRM flag indicates whether the location is a firm or an individual--maybe this could help? Or would it omit too many people?
*/


--Peter Berger LCSW: official office on Alhambra Bl, but has 2nd location on Payne River Cir in Pocket with 19 employees
SELECT 
	coname, 
	staddr, 
	zip,
	locemp,
	naics,
	LMDATE,
	INDFRM,
	ULTNUM,
	HDBRCH
FROM SACOG_Jan_2020
WHERE coname LIKE '%PETER%'
	AND coname LIKE '%BERGER%'

SELECT 
	coname, 
	staddr, 
	zip,
	locemp,
	naics,
	LMDATE,
	INDFRM,
	ULTNUM,
	HDBRCH
FROM SACOG_Jan_2020
WHERE coname LIKE '%BURGER%'
	AND coname LIKE '%KING%'