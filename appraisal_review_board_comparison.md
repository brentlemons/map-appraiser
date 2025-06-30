# Appraisal Review Board Files Comparison

## File Information
- **Current File**: appraisal_review_board_current.csv (148.7 MB)
- **Archive File**: appraisal_review_board_archive.csv (708.9 MB - 4.8x larger)

## Column Differences

### Columns in BOTH files (54 columns):
1. PROTEST_YR
2. ACCOUNT_NUM
3. OWNER_PROTEST_IND
4. MAIL_NAME
5. MAIL_ADDR_L1
6. MAIL_ADDR_L2
7. MAIL_ADDR_L3
8. MAIL_CITY
9. MAIL_STATE_CD
10. MAIL_ZIPCODE
11. NOT_PRESENT_IND
12. LATE_PROTEST_CDX
13. PROTEST_SENT_CDX
14. PROTEST_SENT_DT
15. PROTEST_WD_CDX
16. PROTEST_RCVD_CDX
17. PROTEST_RCVD_DT
18. CONSENT_CDX
19. CONSENT_DT
20. REINSPECT_REQ_CDX
21. REINSPECT_DT
22. RESOLVED_CDX
23. RESOLVED_DT
24. EXEMPT_PROTEST_DESC
25. PREV_SCH_CDX
26. PREV_HEARING_DT
27. PREV_HEARING_TM
28. PREV_ARB_PANEL
29. CERT_MAIL_NUM
30. LESSEE_IND
31. HB201_REQ_IND
32. ARB_PROTEST_IND
33. P2525C1_IND
34. P2525D_IND
35. P41411_IND
36. P4208_IND
37. TAXPAYER_INFO_IND
38. CONSENT_ONREQ_IND
39. EXEMPT_IND
40. AUTH_TAX_REP_ID
41. ARB_PANEL
42. HEARING_DT
43. HEARING_TM
44. EXEMPT_AG_FINAL_ORDERS_CD
45. AUDIO_ACCOUNT_NUM
46. FINAL_ORDER_COMMENT
47. P2525H_IND
48. P2525C2_IND
49. P2525C3_IND
50. P2525B_IND
51. CERT_MAIL_DT
52. NOTIFIED_VAL
53. NEW_VAL
54. PANEL_VAL
55. ACCT_TYPE

### Columns ONLY in Archive file (2 additional columns):
- **VALUE_PROTEST_IND** (position 30, after CERT_MAIL_NUM)
- **NAME** (position 56, at the end)
- **TAXPAYER_REP_ID** (position 57, at the end)

### Columns ONLY in Current file:
- None (Current has fewer columns than Archive)

## Summary

The **Archive file** contains 57 columns while the **Current file** contains 55 columns. The archive file has three additional columns:

1. **VALUE_PROTEST_IND** - Likely indicates whether the protest was about property value
2. **NAME** - Additional name field (possibly owner or representative name)
3. **TAXPAYER_REP_ID** - ID of the taxpayer's representative

The archive file is 4.8x larger than the current file, suggesting it contains historical protest data across multiple years, while the current file likely contains only active/recent protests.

## Data Type Analysis

Based on the column names, this data tracks property tax protests through the Appraisal Review Board process:
- **Protest tracking**: dates received, sent, resolved
- **Communication**: mailing addresses, certified mail tracking
- **Hearing information**: panel assignments, dates, times
- **Values**: notified value, new value, panel-determined value
- **Various indicator flags**: for different types of protests and procedures