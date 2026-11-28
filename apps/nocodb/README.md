# NocoDB

The official NocoDB image (`nocodb/nocodb:2026.11.0`) with a Postgres 17 database and its files on a lasting volume at `/usr/app/data`.

- NocoDB is fair-code under the Sustainable Use License; check that its terms fit your use.
- Setup signs up the first user (the super admin) with the creator's email address on localhost and turns on invite-only sign-up. Traefik routes nothing to the app until the ready file exists.
- Sign in with the creator's email address and the password shown in the console.

## Credit

The `NC_DB` connection string (`pg://host:port?u=...&p=...&d=...`) follows
[railwayapp-templates/nocodb](https://github.com/railwayapp-templates/nocodb):

```
MIT License

Copyright (c) 2023 Railway

Permission is hereby granted, free of charge, to any person obtaining a copy of this software
and associated documentation files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or
substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING
BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
```
