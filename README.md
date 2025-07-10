# CodingChallenge_07-09-2025



iOS Programming Exercise

1. Fetch a list of countries in JSON format from this URL: https://gist.githubusercontent.com/peymano-wmt/32dcb892b06648910ddd40406e37fdab/raw/db25946fd77c5873b0303b858e861ce724e0dcd0/countries.json
2. Display all the countries in a UITableView ordered by the position they appear in the JSON. In each table cell, show the country's "name", "region", "code" and "capital" in this format:
  ---------------------------------------
  |                                     |
  | "name", "region"             "code" |
  |                                     |
  | "capital"                           |
  |                                     |
  ---------------------------------------
  For example:
  ---------------------------------------
  |                                     |
  | United States of America, NA     US |
  |                                     |
  | Washington, D.C.                    |
  |                                     |
  ---------------------------------------
  |                                     |
  | Uruguay, SA                      UY |
  |                                     |
  | Montevideo                          |
  |                                     |
  ---------------------------------------
   
The user should be able to scroll thru the entire list of countries.
3. Use a UISearchController to enable filtering by "name" or "capital" as the user types each character of their search.
The implementation should be robust (i.e., handle errors and edge cases), support Dynamic Type, support iPhone and iPad, and support device rotation.
Please use UIKit, not SwiftUI, for this exercise.
