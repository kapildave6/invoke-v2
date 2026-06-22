import { Detail, Clipboard } from "@raycast/api";
import { useEffect, useState } from "react";

export default function Command() {
  const [md, setMd] = useState("Reading clipboard…");
  useEffect(() => {
    (async () => {
      const current = await Clipboard.read();
      const previous = await Clipboard.read({ offset: 1 });
      const older = await Clipboard.read({ offset: 99 }); // past end → empty
      setMd(
        `# Clipboard History\n\n` +
          `**Current (offset 0):** ${current.text || "_(empty)_"}\n\n` +
          `**Previous (offset 1):** ${previous.text || "_(empty)_"}\n\n` +
          `**Offset 99 (past end):** ${older.text || "_(empty)_"}`,
      );
    })();
  }, []);
  return <Detail markdown={md} />;
}
