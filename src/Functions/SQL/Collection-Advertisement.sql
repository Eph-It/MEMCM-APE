SELECT
    adv.*
FROM
    vSMS_Advertisement adv
WHERE
    adv.CollectionID = @Id

UNION

SELECT
    adv.*
FROM
    vSMS_CollectionDependencies dep
JOIN
    vSMS_Advertisement adv ON adv.CollectionId = dep.DependentCollectionId
WHERE
    dep.SourceCollectionId = @Id
    AND dep.RelationshipType IN (2, 3)
    /*
        RelationshipTypes:
        1 - Limiting collection
        2 - Include collection
        3 - Exclude collection
    */