# Demo Clinical Cortex Analyst Native App 
In this repository I'll walk you through how I built a Cortex Analyst Native App specifically designed for clinical use, leveraging Snowflake's capabilities. This project was inspired by and contains assets from the Medium Blog "Enable Natural Language Querying of Your Snowflake Marketplace Data with Native Apps & Cortex Analyst" by Rachel Blum & Rich Murnane, Snowflake Solution Innovation Team.

Pre-reqs for this application include:
- Clone or download this Snowflake-Labs github repository
- Verify [Cortex Analyst availability](https://docs.snowflake.com/en/user-guide/snowflake-cortex/cortex-analyst#region-availability) in your Snowflake region (currently in PuPr)
- A Snowflake role with elevated privileges (example given in provider.sql script), or the ACCOUNTADMIN role to your Snowflake account


## Apache 2.0 license
```
Copyright 2024 Rich Murnane Snowflake

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
