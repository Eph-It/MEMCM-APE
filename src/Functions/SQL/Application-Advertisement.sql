SELECT
    adv.*
FROM
    vSMS_Advertisement adv
JOIN
    v_TaskSequenceAppReferencesInfo tsa ON tsa.PackageID = adv.PkgID
WHERE
    tsa.RefAppCI_ID = @Id