#!/home/vlt-gui/env/bin/python2.7
# coding:utf-8

"""This file is part of Vulture 3.

Vulture 3 is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

Vulture 3 is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with Vulture 3.  If not, see http://www.gnu.org/licenses/.
"""
__author__ = "Baptiste de Magnienville"
__credits__ = []
__license__ = "GPLv3"
__version__ = "3.0.0"
__maintainer__ = "Vulture Project"
__email__ = "contact@vultureproject.org"
__doc__ = """This migration script update the default ModSec Vulture Rules Set"""

import os
import sys

sys.path.append('/home/vlt-gui/vulture')
os.environ.setdefault("DJANGO_SETTINGS_MODULE", 'vulture.settings')

import django
from bson import ObjectId

django.setup()

from gui.models.modsec_settings import ModSecRulesSet, ModSecRules

if __name__ == '__main__':
    try:
        vulture_rs = ModSecRulesSet.objects.get(name='Vulture RS')
        ModSecRules.objects.filter(rs=ObjectId(vulture_rs.id)).delete()
    except ModSecRulesSet.DoesNotExist as e:
        pass

    from gui.initial_data import modsec_rules_set
    modsec_rules_set.Import().process()

    print "Vulture RS successfully updated"

    ## Write modsec conf
    for m in ModSecRulesSet.objects():
    	conf = m.get_conf()
        m.conf = conf
        m.save()