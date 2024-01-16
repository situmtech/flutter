package com.situm.situm_flutter

import java.io.BufferedReader
import java.io.FileReader
import java.io.IOException

class CPUInfo {
    companion object {
        private fun extractDistinctValuesFromCpuInfo(key: String): List<String> {
            val values = mutableListOf<String>()
            return try {
                BufferedReader(FileReader("/proc/cpuinfo")).use { reader ->
                    var line: String?
                    while (reader.readLine().also { line = it } != null) {
                        if (line!!.contains(key)) {
                            val parts = line!!.split(":")
                            if (parts.size > 1) {
                                values.add(parts[1].trim())
                            }
                        }
                    }
                    values.distinct()
                }
            } catch (e: IOException) {
                e.printStackTrace()
                listOf("Unknown")
            }
        }

        fun getVendors(): List<String> = extractDistinctValuesFromCpuInfo("CPU implementer")
        fun getModels(): List<String> = extractDistinctValuesFromCpuInfo("CPU part")
    }
}
