#!/bin/bash

# Copyright 2016 - 2019 Crunchy Data Solutions, Inc.
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

source /tmp/chemrpsenv

export PGDATA=/pgdata/data



export SUPER_USER=$SUPER_USER
export SUPERUSERPASSWORD=$SUPERUSERPASSWORD

export BCF_AUTH_PASSWORD=$BCF_AUTH_PASSWORD
export BCF_AUTHENTICATORPASSWORD=$BCF_AUTHENTICATORPASSWORD
export BCF_REGPASSWORD=$BCF_REGPASSWORD
export BCF_REG_FACADEPASSWORD=$BCF_REG_FACADEPASSWORD
export DATABASENAME=$DATABASENAME