SELECT
    ass.*
FROM
    v_ApplicationAssignment ass
JOIN 
    fn_ListLatestApplicationCIs(1033) app ON app.ModelID = ass.AppModelID
WHERE
    app.CI_ID = @Id