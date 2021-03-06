#!/usr/bin/python
# -*- coding: utf-8 -*-
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
__author__ = "Jérémie Jourdin"
__credits__ = []
__license__ = "GPLv3"
__version__ = "3.0.0"
__maintainer__ = "Vulture Project"
__email__ = "contact@vultureproject.org"
__doc__ = 'Django forms dedicated to certificate management'

from django.forms import TextInput
from mongodbforms import DocumentForm

from gui.forms.forms_utils import bootstrap_tooltips
from gui.models.ssl_certificate import SSLCertificate


class CertForm(DocumentForm):
    """ Certificate creation form
    """

    def __init__(self, *args, **kwargs):
        super(CertForm, self).__init__(*args, **kwargs)
        self = bootstrap_tooltips(self)

    class Meta:
        document = SSLCertificate
        widgets = {
            'name': TextInput(attrs={'class':'form-control'}),
            'cn': TextInput(attrs={'class':'form-control'}),
            'o': TextInput(attrs={'class':'form-control'}),
            'ou': TextInput(attrs={'class':'form-control'}),
            'c': TextInput(attrs={'class':'form-control'}),
            'st': TextInput(attrs={'class':'form-control'}),
            'l': TextInput(attrs={'class':'form-control'}),

        }

    def clean(self):
        super(CertForm, self).clean()
        return self.cleaned_data
