+++
title = "{{ replace .TranslationBaseName "-" " " | replaceRE "^\\d\\d\\d\\d \\d\\d \\d\\d " "" | title }}"
date = {{ substr .TranslationBaseName 0 10 }}
draft = true
tags = []
topics = []
description = ""
+++