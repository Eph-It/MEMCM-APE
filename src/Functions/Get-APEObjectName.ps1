Function Get-APEObjectName {
    Param(
        [int]$MessageId
    )
    switch ($MessageId) {
        30006 { return "Advertisement" }
        30007 { return "Advertisement" }
        30008 { return "Advertisement" }
        30226 { return "Assignment" }
        30227 { return "Assignment" }
        30228 { return "Assignment" }
        30016 { return "Collection" }
        30152 { return "Application" }
        30001 { return "Package" }
        30068 { return "Package" }
        30004 { return "Program" }
    }
}