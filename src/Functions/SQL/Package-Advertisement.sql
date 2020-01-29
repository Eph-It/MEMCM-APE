SELECT
    adv.*
    ,NULL AS 'ReferenceProgramName'
FROM
    vSMS_Advertisement adv
WHERE
    adv.PkgID = @Id

UNION

SELECT
    adv.*
    ,tsp.ReferenceProgramName
FROM
    vSMS_Advertisement adv
JOIN
    v_TaskSequenceReferencesInfo tsp ON tsp.PackageID = adv.PkgID
WHERE
    tsp.ReferencePackageId = @Id