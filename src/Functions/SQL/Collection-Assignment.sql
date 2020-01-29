SELECT
    ass.*
FROM
    v_ApplicationAssignment ass
WHERE
    ass.CollectionID = @Id

UNION

SELECT
    ass.*
FROM
    vSMS_CollectionDependencies dep
JOIN
    v_ApplicationAssignment ass ON ass.CollectionId = dep.DependentCollectionId
WHERE
    dep.SourceCollectionId = @Id
    AND dep.RelationshipType IN ( 2,3 )
    /*
        RelationshipTypes:
        1 - Limiting collection
        2 - Include collection
        3 - Exclude collection
    */