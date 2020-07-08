
DELETE X
FROM (
SELECT *, ROW_NUMBER() OVER(PARTITION BY A.usersID, A.mainButtonID, A.objectType, A.sortOrder ORDER BY A.userMainButtonID) AS dupRow
FROM HOAIC60_Config.dbo.UserMainButton  AS A
WHERE usersID = 8768
) AS X
WHERE X.dupRow > 1


DELETE X
FROM (
SELECT *, ROW_NUMBER() OVER(PARTITION BY  A.usersID, A.mainMenuID, A.sortOrder ORDER BY A.userMainMenuID) AS dupRow
FROM HOAIC60_Config.dbo.UserMainMenu_Test  AS A
WHERE usersID = 8768
) AS X
WHERE X.dupRow > 1


DELETE X
FROM (
SELECT *, ROW_NUMBER() OVER(PARTITION BY A.usersID, A.userMainMenuID, A.controlPanelID, A.subMenuID, A.sortOrder ORDER BY A.userControlPanelID) AS dupRow
FROM HOAIC60_Config.dbo.UserControlPanel  AS A
WHERE usersID = 8768
) AS X
WHERE X.dupRow > 1


DELETE X
FROM (
SELECT *, ROW_NUMBER() OVER(PARTITION BY A.usersID, A.accessKeysID, A.accessDefaultID, A.hasAccess ORDER BY A.accessUsersID) AS dupRow
FROM HOAIC60_Config.dbo.AccessUsers  AS A
WHERE usersID = 8768
) AS X
WHERE X.dupRow > 1


DELETE X
FROM (
SELECT *, ROW_NUMBER() OVER(PARTITION BY A.reportModuleID, A.reportHeaderID, A.name, A.reportURL, A.infoPageName, A.infoPageURL, A.date, A.company,
										 A.producer, A.header, A.dateSelect, A.lineSelect, A.limitLine, A.stateSelect, A.treatySelect, A.sequenceOrder, A.active,
										 A.idmiDev, A.isClaimReport, A.rptExportOption, A.rptServerOption, A.usersID, A.lastModified, 
										 A.addDate ORDER BY A.reportID) AS dupRow
FROM HOAIC60_Config.dbo.Report  AS A
WHERE usersID = 8768
) AS X
WHERE X.dupRow > 1

DELETE X
FROM (
SELECT *, ROW_NUMBER() OVER(PARTITION BY A.usersID, A.mainMenuID, A.sortOrder ORDER BY A.userMainMenuID) AS dupRow
FROM HOAIC60_Config.dbo.UserMainMenu AS A
WHERE usersID = 8768
) AS X
WHERE X.dupRow > 1

DELETE X
FROM (
SELECT *, ROW_NUMBER() OVER(PARTITION BY A.usersID, A.userMainMenuID, A.subMenuID, A.sortOrder ORDER BY A.userSubMenuID) AS dupRow
FROM HOAIC60_Config.dbo.UserSubMenu  AS A
WHERE usersID = 8768
) AS X
WHERE X.dupRow > 1

DELETE X
FROM (
SELECT *, ROW_NUMBER() OVER(PARTITION BY A.usersID, A.userMainMenuID, A.quickSearchID, A.sortOrder ORDER BY A.userQuickSearchID) AS dupRow
FROM HOAIC60_Config.dbo.UserQuickSearch  AS A
WHERE usersID = 8768
) AS X
WHERE X.dupRow > 1

DELETE X
FROM (
SELECT *, ROW_NUMBER() OVER(PARTITION BY A.usersID, A.reportID, A.hasAccess ORDER BY A.userReportID) AS dupRow
FROM HOAIC60_Config.dbo.UserReport AS A
WHERE usersID = 8768
) AS X
WHERE X.dupRow > 1


/* FIND Duplicate Count */


SELECT COUNT(*)
FROM (
SELECT *, ROW_NUMBER() OVER(PARTITION BY A.usersID, A.mainButtonID, A.objectType, A.sortOrder ORDER BY A.userMainButtonID) AS dupRow
FROM HOAIC60_Config.dbo.UserMainButton  AS A

) AS X
WHERE X.dupRow > 1


SELECT COUNT(*)
FROM (
SELECT *, ROW_NUMBER() OVER(PARTITION BY  A.usersID, A.mainMenuID, A.sortOrder ORDER BY A.userMainMenuID) AS dupRow
FROM HOAIC60_Config.dbo.UserMainMenu_Test  AS A

) AS X
WHERE X.dupRow > 1


SELECT COUNT(*)
FROM (
SELECT *, ROW_NUMBER() OVER(PARTITION BY A.usersID, A.userMainMenuID, A.controlPanelID, A.subMenuID, A.sortOrder ORDER BY A.userControlPanelID) AS dupRow
FROM HOAIC60_Config.dbo.UserControlPanel  AS A

) AS X
WHERE X.dupRow > 1


SELECT COUNT(*)
FROM (
SELECT *, ROW_NUMBER() OVER(PARTITION BY A.usersID, A.accessKeysID, A.accessDefaultID, A.hasAccess ORDER BY A.accessUsersID) AS dupRow
FROM HOAIC60_Config.dbo.AccessUsers  AS A

) AS X
WHERE X.dupRow > 1


SELECT COUNT(*)
FROM (
SELECT *, ROW_NUMBER() OVER(PARTITION BY A.reportModuleID, A.reportHeaderID, A.name, A.reportURL, A.infoPageName, A.infoPageURL, A.date, A.company,
										 A.producer, A.header, A.dateSelect, A.lineSelect, A.limitLine, A.stateSelect, A.treatySelect, A.sequenceOrder, A.active,
										 A.idmiDev, A.isClaimReport, A.rptExportOption, A.rptServerOption, A.usersID, A.lastModified, 
										 A.addDate ORDER BY A.reportID) AS dupRow
FROM HOAIC60_Config.dbo.Report  AS A

) AS X
WHERE X.dupRow > 1

SELECT COUNT(*)
FROM (
SELECT *, ROW_NUMBER() OVER(PARTITION BY A.usersID, A.mainMenuID, A.sortOrder ORDER BY A.userMainMenuID) AS dupRow
FROM HOAIC60_Config.dbo.UserMainMenu AS A

) AS X
WHERE X.dupRow > 1

SELECT COUNT(*)
FROM (
SELECT *, ROW_NUMBER() OVER(PARTITION BY A.usersID, A.userMainMenuID, A.subMenuID, A.sortOrder ORDER BY A.userSubMenuID) AS dupRow
FROM HOAIC60_Config.dbo.UserSubMenu  AS A

) AS X
WHERE X.dupRow > 1

SELECT COUNT(*)
FROM (
SELECT *, ROW_NUMBER() OVER(PARTITION BY A.usersID, A.userMainMenuID, A.quickSearchID, A.sortOrder ORDER BY A.userQuickSearchID) AS dupRow
FROM HOAIC60_Config.dbo.UserQuickSearch  AS A

) AS X
WHERE X.dupRow > 1

SELECT COUNT(*)
FROM (
SELECT *, ROW_NUMBER() OVER(PARTITION BY A.usersID, A.reportID, A.hasAccess ORDER BY A.userReportID) AS dupRow
FROM HOAIC60_Config.dbo.UserReport AS A

) AS X
WHERE X.dupRow > 1
