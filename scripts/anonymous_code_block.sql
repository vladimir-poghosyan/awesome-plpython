-- Instantly run Python code
DO $$
import platform

import plpy


plpy.info(platform.platform())
$$ LANGUAGE 'plpython3u';
