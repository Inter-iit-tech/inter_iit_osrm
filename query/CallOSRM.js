const axios = require("axios")
const XLSX = require("xlsx")
const fs = require("fs")
const { performance } = require("perf_hooks")

const instance = axios.create({
  baseURL: "http://10.10.28.61:5000/",
})
const filename = "1000CoordinatesInBanglore.xlsx"
function getCoords(rows) {
  const workbook = XLSX.readFile(filename, { sheetRows: rows })
  const coords = XLSX.utils.sheet_to_json(workbook.Sheets["Coordinates"], {
    header: 1,
  })
  coords.splice(0, 1)
  return coords
}

async function makestats(rows) {
  const stats = [["No", "Time"]]
  const workbook = XLSX.readFile(filename, { sheetRows: rows })
  const coords = XLSX.utils.sheet_to_json(workbook.Sheets["Coordinates"], {
    header: 1,
  })
  coords.splice(0, 1)
  let CoordinatesString = coords[0][1] + "," + coords[0][2]
  performance.mark("@1")
  console.log(coords)
  for (let i = 1; i < coords.length; i++) {
    CoordinatesString += ";" + coords[i][1] + "," + coords[i][2]
    const CoordinatesStringURL =
      "/table/v1/drive/" +
      CoordinatesString.substring(0, CoordinatesString.length - 2)
    const response = await instance.get(CoordinatesStringURL, {
      params: { annotations: "duration,distance" },
    })
    console.log("index : ", response.data.durations[0].length, i)
    performance.mark(`@${i + 1}`)
    performance.measure(`${i} - ${i + 1}`, `@${i}`, `@${i + 1}`)
    const measure = performance.getEntriesByName(`${i} - ${i + 1}`)[0]
    stats.push([i + 1, measure.duration])
  }
  console.log(stats)
  const newWS = XLSX.utils.json_to_sheet(stats)
  XLSX.utils.book_append_sheet(workbook, newWS)
  XLSX.writeFile(workbook, filename)
}

function getURLStringFromCoords(coords) {
  const CoordinatesString = coords.map((e) => e[1] + "," + e[2]).join(";")
  return "/table/v1/drive/" + CoordinatesString
}

const testfor = (rows) => {
  const coords = getCoords(rows + 1)
  console.log(coords)
  instance.get(getURLStringFromCoords(coords)).then((response) => {
    // console.log(response.data)
    console.log(
      response.data.durations[0].length,
      response.data.durations.length
    )
    fs.writeFileSync("response.json", JSON.stringify(response.data))
  })
}

makestats(200)
